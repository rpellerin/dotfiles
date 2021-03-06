#!/usr/bin/env node

const { exec, spawn } = require('child_process')
const os = require('os')
const fs = require('fs')
const rl = require('readline')
const path = require('path')
const localPkgjson = require(path.resolve(process.cwd(), 'package.json'))

const DEV_DEPENDENCIES = Object.keys(localPkgjson.devDependencies)

const BLACK_LISTED_PACKAGES = [
  'rxjs',
  'shader',
  'react-virtualized',
  'i18n-extract',
  'babel-loader',
  'whatwg-fetch'
]

const testStrings = [
  'a 1.2.3 1.2.5',
  'a 1.2.3 1.2.4',
  'a 1.1.3 1.4.3',
  'a 1.1.3 1.2.5',
  'a 0.2.3 2.2.5',
  'a 0.2.3 1.2.5',
  'a 0.2.3 3.0.5',
  'a 1.2.3 1.2.3',
  'abcsf 1.2.3 2.2.5d'
]

const isVersion = str => str.match(/^\d+\.\d+\.\d+$/)

const sortFromMinorToMajor = (a, b) => {
  const patchDiff = a.differences[2] - b.differences[2]
  const minorDiff = a.differences[1] - b.differences[1]
  const majorDiff = a.differences[0] - b.differences[0]
  return majorDiff !== 0 ? majorDiff : minorDiff !== 0 ? minorDiff : patchDiff
}

const runNpm = async (cmd, cb) => {
  exec(cmd, (error, stdout, stderr) => {
    if (error !== null && (error.killed !== false || error.code !== 1)) {
      console.error(stderr)
      console.log(stdout)
      console.error(error)
      process.exit(1)
    }
    cb(stdout)
  })
}

const runWithOutput = async (string, args = []) =>
  new Promise(resolve => {
    const [cmd, ...args2] = string.split(' ')
    const proc = spawn(cmd, [...args2, ...args])

    proc.stdout.on('data', data => process.stdout.write(data))
    proc.stderr.on('data', data => process.stderr.write(data))

    proc.on('close', code => resolve(code))
  })

const allPreviousDigitsMatch = (oldSplit, newSplit, index) => {
  for (let i = index - 1; i >= 0; i--) {
    if (oldSplit[i] !== newSplit[i]) return false
  }
  return true
}

const formatAndGetUrl = ({ name, _properties }) =>
  new Promise(resolve => {
    const ret = [name, _properties.current, _properties.latest]
    fs.readFile(`${_properties.location}/package.json`, 'utf8', (err, data) => {
      let location = null
      if (!err) {
        try {
          const pkgjson = JSON.parse(data)
          location =
            (pkgjson.repository && pkgjson.repository.url) ||
            pkgjson.homepage ||
            'Unknown'
          location = location
            .replace(/^git\+https/, 'https')
            .replace(/\.git$/, '')
        } catch (ignore) {}
      }
      resolve([...ret, location])
    })
  })

const computePackagesToUpgrade = async outdatedPackages =>
  (await Promise.all(outdatedPackages.map(formatAndGetUrl)))
    .filter(
      ([name, oldVersion, newVersion, url]) =>
        isVersion(oldVersion) && isVersion(newVersion)
    )
    .map(([name, oldVersion, newVersion, url]) => {
      const oldSplit = oldVersion.split('.')
      const newSplit = newVersion.split('.')
      const differences = oldSplit.map(
        (number, i, arr) => {
          if (i === 0 || allPreviousDigitsMatch(oldSplit, newSplit, i))
            return newSplit[i] - number
          return +newSplit[i]
        },
        { bitsInCommon: 0, majorDiff: 0, minorDiff: 0, patchDiff: 0 }
      )

      const dev = DEV_DEPENDENCIES.includes(name)
      const obj = { name, differences, oldVersion, newVersion, url, dev }
      return obj
    })
    .filter(({ differences }) => differences.some(diff => diff !== 0)) // removes those with no differences
    .filter(({ name }) => !BLACK_LISTED_PACKAGES.includes(name))
    .sort(sortFromMinorToMajor)

const ask = async (question, callback) =>
  new Promise(resolve => {
    const r = rl.createInterface({
      input: process.stdin,
      output: process.stdout
    })
    r.question(question + '\n', answer => {
      r.close()
      resolve(answer)
    })
  })

runNpm('npm outdated --json', async result => {
  const rawResult = JSON.parse(result)
  const formattedResult = Object.keys(rawResult).map(name => ({
    name,
    _properties: rawResult[name]
  }))
  const packagesToUpdate = await computePackagesToUpgrade(formattedResult)
  console.table(packagesToUpdate)
  const response = await ask('Continue? [Y/n]')
  if (!response.match(/^[Yy]/)) {
    process.exit(0)
  }
  for (let i = 0; i < packagesToUpdate.length; i++) {
    const { name, oldVersion, newVersion, dev } = packagesToUpdate[i]
    console.log(`Updating ${name}...`)

    let returnCode = await runWithOutput(
      `npm install ${dev ? '-D' : ''} ${name}@^${newVersion}`
    )
    if (returnCode !== 0) process.exit(1)

    returnCode = await runWithOutput('git add -A')
    if (returnCode !== 0) process.exit(1)

    const commigMessage = `chore(npm): Upgrade ${name} from ${oldVersion} to ${newVersion}`
    returnCode = await runWithOutput('git commit -m', [
      commigMessage,
      '-m',
      'UPGRADE-NPM-PACKAGES'
    ])
    if (['--push', '-p'].includes(process.argv[2])) {
      await runWithOutput('git push')
    }
    if (returnCode !== 0) process.exit(1)

    console.log(commigMessage)
  }
})
