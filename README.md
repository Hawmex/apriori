# Association Rules Learning with Apriori

This is a command-line application written in Dart that can be used to uncover
association rules in transactions.

## Getting Started

### Install the Application

```
cd ..
```

```
dart pub global activate apriori -s=path
```

### Prepare Input Files

You need to prepare two files:

- A JSON file containing your transactions.
- A JSON containing your settings and preferences.

#### Transactions Scheme

Using TypeScript types:

```ts
type Transactions = string[][];
```

#### Options Scheme

Using TypeScript types:

```ts
type Options = {
  transactionsPath: string;
  rulesPath: string;
  minSupport: number;
  minConfidence: number;
  maxAntecedentsLength: number;
};
```

### Run the Application

Then you can run the application through the command line:

```
apriori options.json
```

## Example

### `transactions.json`

```json
[
  ["tropical fruit", "yogurt", "coffee"],
  ["whole milk"],
  ["pip fruit", "yogurt", "cream cheese", "meat spreads"]
  //...
]
```

### `options.json`

```json
{
  "transactionsPath": "transactions.json",
  "rulesPath": "rules.json",
  "minSupport": 0.006,
  "minConfidence": 0.07
}
```

### Learning the Association Rules

```
apriori options.json
```

You can find look at [`example/`](./example/) for more information.

## Performance

This application can extract the association rules in [`example/`] in ~55
seconds
