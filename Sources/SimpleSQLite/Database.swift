import Foundation
import SQLite3

public class Database {
	public enum Error: Swift.Error {
		case unableToOpen
		case couldNotPrepareStatement
	}

	private let path: URL

	private var db: OpaquePointer

	public init(path: URL) throws {
		self.path = path

		db = try Self.open(path: path)
	}

	deinit {
		sqlite3_close(db)
	}

	public func run(with query: String, parameters: [Value] = []) throws {
		try createQuery(with: query)
			.bind(parameters: parameters)
			.run()
	}

	public func scalar(with query: String, parameters: [Value] = []) throws -> Value? {
		try createQuery(with: query)
			.bind(parameters: parameters)
			.scalar()
	}

	public func row<C: Column>(with query: String, columns: C.Type, parameters: [Value] = []) throws -> Row<C>? {
		try createQuery(with: query)
			.bind(parameters: parameters)
			.row(columns: columns)
	}

	public func rows<C: Column>(with query: String, columns: C.Type, parameters: [Value] = []) throws -> RowSet<C>? {
		try createQuery(with: query)
			.bind(parameters: parameters)
			.rows(columns: columns)
	}

	public func getErrorMessage() -> String {
		String(cString: sqlite3_errmsg(db))
	}

	private func createQuery(with query: String) throws -> Statement {
		var statement: OpaquePointer?

		guard
			sqlite3_prepare_v2(db, query.cString(using: .utf8), -1, &statement, nil) == SQLITE_OK,
			let unwrappedStatement = statement
		else {
			throw Error.couldNotPrepareStatement
		}

		return Statement(statement: unwrappedStatement, database: self)
	}

	private static func open(path: URL) throws -> OpaquePointer {
		var db: OpaquePointer?

		guard
			sqlite3_open(path.absoluteString, &db) == SQLITE_OK,
			let unwrappedDb = db
		else {
			throw Error.unableToOpen
		}

		return unwrappedDb
	}
}
