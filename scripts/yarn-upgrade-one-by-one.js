#!/usr/bin/env node

const { exec, spawn } = require('child_process')
const os = require('os')
const rl = require('readline')

const BLACK_LISTED_PACKAGES = ['rxjs', 'react-virtualized', 'i18n-extract', 'whatwg-fetch']

const testStrings = [
    'a 1.2.3 1.2.5',
    'a 1.2.3 1.2.4',
    'a 1.1.3 1.4.3',
    'a 1.1.3 1.2.5',
    'a 0.2.3 2.2.5',
    'a 0.2.3 1.2.5',
    'a 0.2.3 3.0.5',
    'a 1.2.3 1.2.3',
    'abcsf 1.2.3 2.2.5d',
]

const isVersion = str => str.match(/^\d+\.\d+\.\d+$/)

const sortFromMinorToMajor = (a, b) => {
    const patchDiff = a.differences[2] - b.differences[2]
    const minorDiff = a.differences[1] - b.differences[1]
    const majorDiff = a.differences[0] - b.differences[0]
    return (majorDiff !== 0 ? majorDiff : minorDiff !== 0 ? minorDiff : patchDiff)
}

const run = async (cmd, cb) => {
    exec(cmd, (error, stdout, stderr) => {
        if (error !== null) {
            console.error(stderr)
            console.error(error)
            process.exit(1)
        }
        cb(stdout)
    })
}

const runWithOutput = async (string, args = []) => new Promise(resolve => {
    const [cmd, ...args2] = string.split(' ')
    const proc = spawn(cmd, [...args2, ...args])

    proc.stdout.on('data', (data) => process.stdout.write(data))
    proc.stderr.on('data', (data) => process.stderr.write(data))

    proc.on('close', (code) => resolve(code))
})

const allPreviousDigitsMatch = (oldSplit, newSplit, index) => {
    for (let i = index - 1; i >= 0; i--) {
        if (oldSplit[i] !== newSplit[i]) return false
    }
    return true
}

const computePackagesToUpgrade = outdatedPackages => outdatedPackages
    .filter(s => s && s.trim().length > 0)
    .map(s => s.split(' '))
    .filter(([name, oldVersion, newVersion, url]) => isVersion(oldVersion) && isVersion(newVersion))
    .map(([name, oldVersion, newVersion, url]) => {
        const oldSplit = oldVersion.split('.')
        const newSplit = newVersion.split('.')
        const differences = oldSplit.map((number, i, arr) => {
            if (i === 0 || allPreviousDigitsMatch(oldSplit, newSplit, i)) return newSplit[i] - number
            return +newSplit[i]
        }, { bitsInCommon: 0, majorDiff: 0, minorDiff: 0, patchDiff: 0 })

        const obj = { name, differences, oldVersion, newVersion, url }
        return obj
    })
    .filter(({ differences }) => differences.some(diff => diff !== 0)) // removes those with no differences
    .filter(({ name }) => !BLACK_LISTED_PACKAGES.includes(name))
    .sort(sortFromMinorToMajor)

const ask = async (question, callback) => new Promise(resolve => {
    const r = rl.createInterface({
        input: process.stdin,
        output: process.stdout
    })
    r.question(question + '\n', answer => {
        r.close()
        resolve(answer)
    })
})

run("yarn outdated | tail -n +7 | head -n -1 | awk '{print $1,$2,$4,$6}'", async result => {
    const packagesToUpdate = computePackagesToUpgrade(result.split(os.EOL))
    console.table(packagesToUpdate)
    const response = await ask('Continue? [Y/n]')
    if (!response.match(/^[Yy]/)) {
        process.exit(0)
    }
    for (let i = 0; i < packagesToUpdate.length; i++) {
        const { name, oldVersion, newVersion } = packagesToUpdate[i]
        console.log(`Updating ${name}...`)

        let returnCode = await runWithOutput(`yarn upgrade ${name} --latest`)
        if (returnCode !== 0) process.exit(1)

        returnCode = await runWithOutput('git add -A')
        if (returnCode !== 0) process.exit(1)

        const commigMessage = `chore(npm): Upgrade ${name} from ${oldVersion} to ${newVersion}`
        returnCode = await runWithOutput('git commit -m', [commigMessage, '-m', 'UPGRADE-NPM-PACKAGES'])
        if (['--push', '-p'].includes(process.argv[2])) {
            await runWithOutput('git push')
        }
        if (returnCode !== 0) process.exit(1)

        console.log(commigMessage)
    }
});
