import Foundation

public struct Row<T: Column> {
	private let values: [String: Value]

	init(values: [String: Value]) {
		self.values = values
	}

	/// Get value by using [] syntax
	public subscript(_ column: T) -> Value? {
		values[column.name]
	}

	/// Retrieves string value for provided column
	public func string(for column: T) -> String? {
		values[column.name]?.asString
	}

	/// Retrieves data value for provided column
	public func data(for column: T) -> Data? {
		values[column.name]?.asData
	}

	/// Retrieves double value for provided column
	public func double(for column: T) -> Double? {
		values[column.name]?.asDouble
	}

	/// Retrieves double value for provided column
	public func bool(for column: T) -> Bool? {
		values[column.name]?.asBool
	}

	/// Retrieves int value for provided column
	public func int(for column: T) -> Int? {
		values[column.name]?.asInt
	}
}
