# MongoDB Query Evaluator Action

This action evaluate MongoDB MQLs projects by executing queries into a MongoDB docker container and comparing with the expected results

## Evaluator Action

To call the evaluator action you must create `.github/workflows/main.yml` in the project repo with the MongoDB docker container

You must provide the `DBNAME` envvar and set the inputs (detailed below):

```yml
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  evaluator_job:
    name: Evaluator Job
    runs-on: ubuntu-18.04
    services:
      mongodb:
        image: mongo
        ports:
          - "27017:27017"
        options: -v ${{ github.workspace }}:/github/workspace
    steps:
      - uses: actions/checkout@v2
      - name: MongoDB Query Evaluator Step
        uses: betrybe/mongodb-query-evaluator-action@master
        id: mongodb-query-evaluator
        env:
          DBNAME: 'aggregations'
        with:
          repository-import-folder: 'assets'
          repository-challenges-folder: 'challenges'
      - name: Store evaluation step
        uses: betrybe/store-evaluation-action@v2
        with:
          evaluation-data: ${{ steps.evaluator.outputs.result }}
          environment: staging
          pr-number: ${{ github.event.number }}

```

### Inputs

#### `repository-import-folder`

GitHub repository on master dir that contains the `.bson` (compressed or not in `.tar.gz`) with the dataset collections to restore

```
# Example
assets/
|--movies.bson
|--airlines.tar.gz
```

#### `repository-challenges-folder`

GitHub repository on student branch dir that contains the MQLs (e.g. `db.movies.find({})`) files with `.js` extension

```
# Example
challenges/
|--desafio1.js
|--desafio2.js
|--...
```

### Outputs

#### `result`

Evaluation result JSON in base64 format.

#### `pr-number`

Pull Request number that trigger build.

## Trybe requirements and expected results

Project repository must create a file called `requirements.json` inside `.trybe` folder.

This file should have the following structure:

```json
{
  "requirements": [
    {
      "identifier": "desafio1",
      "description": "requirement #1",
      "bonus": false
    },
    {
      "identifier": "desafio2",
      "description": "requirement #2",
      "bonus": true
    },
    {
      "identifier": "desafio3",
      "description": "requirement #3",
      "bonus": false
    }
  ]
}
```

where the `"requirement #1"`, `"requirement #2"` and `"requirement #3"` are the requirements and describes names.

## Expected results

You also must add the expected query results on your project repo into `.trybe/expected-results` folder

```
# Example
.trybe/expected-results/
|--desafio1
|--desafio2
|--...
```

## Learn about GitHub Actions

- https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-a-docker-container-action
