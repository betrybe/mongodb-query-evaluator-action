# MongoDB Query Evaluator Action

This action evaluate MongoDB MQLs projects by executing queries into a MongoDB docker container and comparing with the expected results

## Evaluator Action

To call the evaluator action you must create `.github/workflows/main.yml` in the project repo with the MongoDB docker container

You should check the last release [here](https://github.com/betrybe/mongodb-query-evaluator-action/releases) to use the most recent stable version of the evaluator.

You must provide the `DBNAME` envvar and set the inputs (detailed below):

```yml
on:
  workflow_dispatch:
    inputs:
      dispatch_token:
        description: 'Token that authorize the dispatch'
        required: true
      head_sha:
        description: 'Head commit SHA that dispatched the workflow'
        required: true
      pr_author_username:
        description: 'Pull Request author username'
        required: true
      pr_number:
        description: 'Pull Request number that dispatched the workflow'
        required: true

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
        uses: betrybe/mongodb-query-evaluator-action@v4
        id: mongodb_evaluator
        env:
          DBNAME: 'aggregations'
        with:
          db_restore_dir: 'assets'
          challenges_dir: 'challenges'
          pr_author_username: ${{ github.event.inputs.pr_author_username }}
      - name: Store evaluation step
        uses: betrybe/store-evaluation-action@v2
        with:
          evaluation-data: ${{ steps.mongodb_evaluator.outputs.result }}
          environment: staging
          pr-number: ${{ github.event.inputs.pr_number }}

```

### Inputs

This action accepts the following configuration parameters via `with:`

- `db_restore_dir`

  **Required**

  GitHub repository directory that contains the dataset collections to be restored.

- `challenges_dir`

  **Required**

  GitHub repository directory that contains the student MQL scripts.

- `pr_author_username`

  **Required**

  Pull Request author username.

## Outputs

- `result`

  MongoDB Query evaluator JSON results in base64 format.

##### Observations

1. The original `.bson` file will have its name the same as the collection's (e.g. `movies.bson` collection will be `movies`).

2. For each `.tar.gz` file you must create a dump folder and put such file in it.

  * If you have a correspondent `.json` metadata file originated from the MongoDB dumping process, you may put it into the folder as well.

3. If a dump folder contains one `tar.gz` file whose size is greater than `10MB`, you **must split** the file into pieces and put them in a subfolder called `splitted-files`. This must happen due to a GitHub restriction that does not allow a template repository to have any file whose size is greater than `10MB`. In order to split the file, you must use the [`split`](https://man7.org/linux/man-pages/man1/split.1.html) command. For example, suppose you have a file called `voos.tar.gz` (whose size is `20MB`) and you want to split it into `10MB` files, `voos.tar.gz.part-aa` and `voos.tar.gz.part-ab`. You can achieve this by doing:

```bash
split -b 10m voos.tar.gz voos.tar.gz.part-
```

  * The `splitted-files` folder **must contain only the splitted files originated from the split operation**;

  * You **cannot** have more than one `splitted-files` folder in the same dump folder;

  * If you have a dump folder with the `splitted-files` subfolder, you **cannot** have a `dump.tar.gz` inside the dump folder, as this name is reserved for recreating the original compressed file located at the `splitted-files` subfolder.

---

Suppose you have set the `assets` directory for the `db_restore_dir` input. Here follows an example showing the `assets` directory containing the necessary files to be restored, listing the possible cases covered by the evaluator.

```
assets/
|--first-dump/
|----compressed-first-dump-file.tar.gz
|--another-dump/
|----another-dump.metadata.json
|----splitted-files/
|------compressed-dump-file-part-aa
|------compressed-dump-file-part-ab
|------compressed-dump-file-part-ac
|--another-one-dump/
|----splitted-files/
|------compressed-dump-file-part-aa
|------compressed-dump-file-part-ab
|------compressed-dump-file-part-ac
|------compressed-dump-file-part-ad
```

#### `challenges_dir`

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
