import Foundation
import SQLite3

public final class Statement {
	public enum Error: Swift.Error {
		case binding
		case execute(message: String)
		case reading
		case isFinalized
	}

	private static let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

	private let database: Database

	let sqliteStatement: OpaquePointer

	private var isFinalized: Bool = false

	init(statement: OpaquePointer, database: Database) {
		sqliteStatement = statement

		self.database = database
	}

	deinit {
		finalize()
	}

	func bind(parameters values: [Value]) throws -> Statement {
		guard isFinalized == false else {
			throw Error.isFinalized
		}

		var position: Int32 = 1

		for value in values {
			switch value {
			case .double(let actualValue):
				try bind(actualValue, at: position)
			case .string(let actualValue):
				try bind(actualValue, at: position)
			case .int(let actualValue):
				try bind(actualValue, at: position)
			case .data(let actualValue):
				try bind(actualValue, at: position)
			case .null:
				try bindNull(at: position)
			}

			position += 1
		}

		return self
	}

	func run() throws {
		guard isFinalized == false else {
			throw Error.isFinalized
		}

		sqlite3_step(sqliteStatement)
	}

	func scalar() throws -> Value? {
		enum NoColumns: String, Column {
			case none
		}

		return try RowSet(statement: self, columns: NoColumns.self).readSingleValue()
	}

	func row<C: Column>(columns: C.Type) throws -> Row<C>? {
		try RowSet(statement: self, columns: C.self).readRow()
	}

	func rows<C: Column>(columns: C.Type) throws -> RowSet<C>? {
		RowSet(statement: self, columns: C.self)
	}

	func finalize() {
		guard isFinalized == false else {
			return
		}

		sqlite3_clear_bindings(sqliteStatement)
		sqlite3_finalize(sqliteStatement)

		isFinalized = true
	}

	private func bind(_ value: String, at position: Int32) throws {
		guard
			sqlite3_bind_text(sqliteStatement, position, value.cString(using: .utf8), -1, Self.sqliteTransient) == SQLITE_OK
		else {
			throw Error.binding
		}
	}

	private func bind(_ value: Double, at position: Int32) throws {
		guard sqlite3_bind_double(sqliteStatement, position, value) == SQLITE_OK else {
			throw Error.binding
		}
	}

	private func bind(_ value: Int, at position: Int32) throws {
		guard sqlite3_bind_int64(sqliteStatement, position, sqlite3_int64(value)) == SQLITE_OK else {
			throw Error.binding
		}
	}

	private func bind(_ value: Data, at position: Int32) throws {
		try value.withUnsafeBytes { bufferPointer in
			guard
				sqlite3_bind_blob(
					sqliteStatement,
					position,
					bufferPointer.baseAddress,
					Int32(value.count),
					Self.sqliteTransient
				) == SQLITE_OK
			else {
				throw Error.binding
			}
		}
	}

	private func bindNull(at position: Int32) throws {
		guard sqlite3_bind_null(sqliteStatement, position) == SQLITE_OK else {
			throw Error.binding
		}
	}
}
