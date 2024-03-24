# SimpleSQLite

This package provides a basic wrapper around the C API from the SQLite3 framework. There is still plenty to 
add but the basics work.

## Examples

### Open or create database

```			
let database = try Database(path: fileURL)
```

### Insert data

```
try database.run(with: """
	CREATE TABLE planet (
		id INTEGER PRIMARY KEY,
		name TEXT NOT NULL,
		distance REAL NOT NULL,
		habitable BOOL NOT NULL
	);
	""")

for planet in planets {
	try database.run(
		with: """
			INSERT INTO planet (id, name, distance, habitable)
			VALUES (?, ?, ?, ?);
			""",
		parameters: [
			.int(planet.id),
			.string(planet.name),
			.double(planet.distance),
			.bool(planet.habitable),
		]
	)
}
```

### Query data

Describe columns by using an enum:

```
private enum PlanetColumn: String, Column {
	case id
	case name
	case distance
	case habitable
}
```

#### Single row

```
do {
	guard let result = try database.row(with: "SELECT * FROM planet ORDER BY id;", columns: PlanetColumn.self) else {
		return
	}

	XCTAssertNotNil(result)

	let id = result.int(for: .id)
	let name = result.string(for: .name)
	let distance = result.double(for: .distance)
	let habitable = result!.bool(for: .habitable)
} catch {}
```

#### Multiple rows

```
do {
	guard let rows = try database.rows(with: "SELECT * FROM planet ORDER BY id;", columns: PlanetColumn.self) else {
		return
	}

	while row = try rows.readRow() {
		let id = row.int(for: .id)
		
		// etc
	}
} catch {
	XCTFail(error.localizedDescription)
}
```
