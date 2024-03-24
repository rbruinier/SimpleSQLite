import XCTest
@testable import SimpleSQLite

final class SimpleSQLiteTests: XCTestCase {
	private struct Planet {
		let id: Int
		let name: String
		let distance: Double
		let habitable: Bool
	}

	private enum PlanetColumn: String, Column {
		case id
		case name
		case distance
		case habitable
	}

	private let testDbPath = URL(fileURLWithPath: "test.db")

	private let planets: [Planet] = [
		.init(id: 1, name: "Mercury", distance: 60_000_000, habitable: false),
		.init(id: 2, name: "Venus", distance: 100_000_000, habitable: false),
		.init(id: 3, name: "Earth", distance: 150_000_000, habitable: true),
		.init(id: 4, name: "Mars", distance: 220_000_000, habitable: false),
		.init(id: 5, name: "Jupiter", distance: 780_000_000, habitable: false),
		.init(id: 6, name: "Saturn", distance: 1_420_000_000, habitable: false),
		.init(id: 7, name: "Uranus", distance: 2_870_000_000, habitable: false),
		.init(id: 8, name: "Neptune", distance: 4_500_000_000, habitable: false),
	]

	override func setUp() {
		createTestDatabase()
	}

	override func tearDown() {
		try! FileManager.default.removeItem(at: testDbPath)
	}

	func testScalar() throws {
		let database = try! Database(path: testDbPath)

		do {
			let result = try database.scalar(with: "SELECT COUNT(*) FROM planet;")

			XCTAssertEqual(result?.asInt, planets.count)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	func testSingleRow() throws {
		let database = try! Database(path: testDbPath)

		do {
			let result = try database.row(with: "SELECT * FROM planet ORDER BY id;", columns: PlanetColumn.self)

			XCTAssertNotNil(result)

			XCTAssertEqual(result!.int(for: .id), planets[0].id)
			XCTAssertEqual(result!.string(for: .name), planets[0].name)
			XCTAssertEqual(result!.double(for: .distance), planets[0].distance)
			XCTAssertEqual(result!.bool(for: .habitable), planets[0].habitable)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	func testRowSet() throws {
		let database = try! Database(path: testDbPath)

		do {
			let rows = try database.rows(with: "SELECT * FROM planet ORDER BY id;", columns: PlanetColumn.self)

			XCTAssertNotNil(rows)

			for planet in planets {
				let row = try rows!.readRow()

				XCTAssertNotNil(row)

				XCTAssertEqual(row!.int(for: .id), planet.id)
				XCTAssertEqual(row!.string(for: .name), planet.name)
				XCTAssertEqual(row!.double(for: .distance), planet.distance)
				XCTAssertEqual(row!.bool(for: .habitable), planet.habitable)
			}
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	private func createTestDatabase() {
		do {
			let database = try Database(path: testDbPath)

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
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
}
