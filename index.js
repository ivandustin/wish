#!/usr/bin/env node
const assert = require('assert')
const fs = require('fs')
const { spawnSync } = require('child_process')
const os = require('os')
const crypto = require('crypto')
const mustache = require('mustache')
const package = require('./package.json')

var settings = {
    name: null,
    manufacturer: null,
    version: null,
    staging: null,
    template: `${__dirname}/main.wxs.tpl`,
    is32bit: false
}

function main() {
    getargs()
    checksettings()
    mkwix(mkview())
    heat(settings.staging)
    candle()
    light()
}

function mkwix(view) {
    var tpl = fs.readFileSync(settings.template).toString()
    mustache.parse(tpl)
    var out = mustache.render(tpl, view)
    fs.writeFileSync('main.wxs', out)
}

function heat(dir) {
    cmd('heat', ['dir', dir, '-gg', '-ke', '-srd', '-cg', 'STAGINGDIRECTORY',
        '-dr', 'APPLICATIONROOTDIRECTORY', '-o', 'staging.wxs'])
}

function candle() {
    cmd('candle', ['staging.wxs', 'main.wxs', '-arch', getarch()])
}

function light() {
    cmd('light', ['-ext', 'WixUIExtension', '-ext', 'WixUtilExtension',
        '-b','staging', 'main.wixobj', 'staging.wixobj', '-o', filename() + '.msi'])
}

function cmd(a, b) {
    var result = spawnSync(a, b)
    assert(result.status == 0, result.output)
}

function mkview() {
    return {
        id: hash(`${settings.name}${settings.manufacturer}${settings.version}`),
        upgradeCode: hash(`${settings.name}${settings.manufacturer}`),
        name: settings.name,
        manufacturer: settings.manufacturer,
        version: settings.version,
        hasPostInstall: hasPostInstall(),
        hasPreUninstall: hasPreUninstall(),
        is32bit: settings.is32bit
    }
}

function filename() {
    return `${settings.manufacturer} ${settings.name} ${settings.version} ${getarch()}`
}

function hasPostInstall() {
    return fs.existsSync(`${settings.staging}/bin/postinstall.bat`)
}

function hasPreUninstall() {
    return fs.existsSync(`${settings.staging}/bin/preuninstall.bat`)
}

function getarch() {
    return settings.is32bit ? 'x86' : 'x64'
}

function getargs() {
    var args = process.argv.slice(2)
    getopt(args, function(option, value) {
        switch(option) {
            case 'n':
                settings.name = value
                return true
            case 'm':
                settings.manufacturer = value
                return true
            case 'v':
                settings.version = value
                return true
            case '32bit':
                settings.is32bit = true
                return false
            case 'help':
                printhelp()
                return process.exit(0)
            default:
                settings.staging = value
                return
        }
    })
}

function checksettings() {
    assert(settings.version, 'missing version')
    assert(settings.name, 'missing app name')
    assert(settings.manufacturer, 'missing manufacturer')
    assert(fs.existsSync(settings.staging), 'target directory does not exist')
}

function hash(data) {
    var hash = crypto.createHash('sha256')
    hash.update(data)
    return hash.digest('hex').toString().substring(0, 8)
}

function printhelp() {
    var msg = [
        'Usage: wish <target directory> -n <app name> -m <vendor name> -v <version> [options...]',
        'Options:',
        '    -n <name>    Application name',
        '    -m <name>    Vendor name or manufacturer',
        '    -v <version> Semantic version (e.g. 1.2.3)',
        '    --32bit      Optional. If specified, create x86 installer',
        '',
        `${package.name} - ${package.description}`,
        '',
        '',
        'GRACE AND PEACE TO YOU FROM OUR LORD JESUS CHRIST. JESUS LOVES YOU.'
    ]
    msg.forEach((str)=> console.log(str))
}

function getopt(argv, handle) {
    for(var i=0; i<argv.length; i++) {
        var arg = argv[i]
        var opt = '', value = ''
        if (!arg) return
        if (arg[0] == '-' && arg.length == 2) {
            opt = arg[1]
            value = argv[i+1]
        } else if (arg.substring(0, 2) == '--') {
            opt = arg.substring(2)
            value = argv[i+1]
        } else {
            opt = null
            value = arg
        }
        var hasValue = handle(opt, value)
        if (hasValue) i++
    }
}

try {
    main()
} catch (e) {
    console.error(`ERROR: ${e.message}`)
    process.exit(1)
}
