import Foundation
import SQLite3

public final class RowSet<C: Column> {
	public enum Error: Swift.Error {
		case reading
		case isFinalized
	}

	private let statement: Statement

	private var columnNames: [String]?

	init(statement: Statement, columns: C.Type) {
		self.statement = statement
	}

	func readSingleValue() throws -> Value? {
		guard sqlite3_step(statement.sqliteStatement) == SQLITE_ROW else {
			return nil
		}

		return try readValue(forColumn: 0)
	}

	func readRow() throws -> Row<C>? {
		let columns = try columnNames ?? readColumnNames()

		return try readRow(columns: columns)
	}

	func readAllRows<T: Column>(columns: T.Type) throws -> [Row<T>]? {
		let columns = try columnNames ?? readColumnNames()

		var rows: [Row<T>] = []

		while let row: Row<T> = try readRow(columns: columns) {
			rows.append(row)
		}

		return rows
	}

	private func readRow<T: Column>(columns: [String]) throws -> Row<T>? {
		guard sqlite3_step(statement.sqliteStatement) == SQLITE_ROW else {
			return nil
		}

		var row: [String: Value] = [:]

		for (columnIndex, columnName) in columns.enumerated().map({ (Int32($0.offset), $0.element) }) {
			row[columnName] = try readValue(forColumn: columnIndex)
		}

		return Row(values: row)
	}

	private func readColumnNames() throws -> [String] {
		let columnCount = sqlite3_column_count(statement.sqliteStatement)

		let columnNames: [String] = try (0 ..< columnCount).map {
			guard let name = String(cString: sqlite3_column_name(statement.sqliteStatement, $0), encoding: .utf8) else {
				throw Error.reading
			}

			return name
		}

		self.columnNames = columnNames

		return columnNames
	}

	private func readValue(forColumn columnIndex: Int32) throws -> Value {
		let columnType = sqlite3_column_type(statement.sqliteStatement, columnIndex)

		switch columnType {
		case SQLITE_INTEGER:
			return .int(Int(sqlite3_column_int64(statement.sqliteStatement, columnIndex)))
		case SQLITE_FLOAT:
			return .double(sqlite3_column_double(statement.sqliteStatement, columnIndex))
		case SQLITE_BLOB:
			let data = sqlite3_column_text(statement.sqliteStatement, columnIndex)!
			let nrOfBytes = sqlite3_column_bytes(statement.sqliteStatement, columnIndex)

			return .data(Data(bytes: data, count: Int(nrOfBytes)))
		case SQLITE_TEXT:
			let data = sqlite3_column_text(statement.sqliteStatement, columnIndex)!
			let nrOfBytes = sqlite3_column_bytes(statement.sqliteStatement, columnIndex)

			if let value = String(data: Data(bytes: data, count: Int(nrOfBytes)), encoding: .utf8) {
				return .string(value)
			} else {
				return .null
			}
		case SQLITE_NULL:
			return .null
		default:
			throw Error.reading
		}
	}
}
