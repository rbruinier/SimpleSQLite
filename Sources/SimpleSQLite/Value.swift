import Foundation

public enum Value: Equatable {
	case string(_ value: String)
	case double(_ value: Double)
	case data(_ value: Data)
	case int(_ value: Int)
	case null

	static func bool(_ value: Bool) -> Value {
		.int(value ? 1 : 0)
	}

	public var asString: String? {
		guard case .string(let value) = self else {
			return nil
		}

		return value
	}

	public var asDouble: Double? {
		guard case .double(let value) = self else {
			return nil
		}

		return value
	}

	public var asBool: Bool? {
		guard case .int(let value) = self else {
			return nil
		}

		return value == 1
	}

	public var asData: Data? {
		guard case .data(let value) = self else {
			return nil
		}

		return value
	}

	public var asInt: Int? {
		guard case .int(let value) = self else {
			return nil
		}

		return value
	}

	public var isNull: Bool {
		self == .null
	}
}
