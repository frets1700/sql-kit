public protocol SQLInsert: SQLSerializable {
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    associatedtype Expression: SQLExpression
    associatedtype Upsert: SQLUpsert

    static func insert(_ table: TableIdentifier) -> Self
    var columns: [ColumnIdentifier] { get set }
    var values: [[Expression]] { get set }
    var upsert: Upsert? { get set }
}

// MARK: Generic

public struct GenericSQLInsert<TableIdentifier, ColumnIdentifier, Expression, Upsert>: SQLInsert
    where TableIdentifier: SQLTableIdentifier, ColumnIdentifier: SQLColumnIdentifier, Expression: SQLExpression, Upsert: SQLUpsert
{
    public typealias `Self` = GenericSQLInsert<TableIdentifier, ColumnIdentifier, Expression, Upsert>
    
    /// See `SQLInsert`.
    public static func insert(_ table: TableIdentifier) -> Self {
        return .init(table: table, columns: [], values: [], upsert: nil)
    }
    
    public var table: TableIdentifier
    public var columns: [ColumnIdentifier]
    public var values: [[Expression]]
    public var upsert: Upsert?
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("INSERT INTO")
        sql.append(table.serialize(&binds))
        sql.append("(" + columns.serialize(&binds) + ")")
        sql.append("VALUES")
        sql.append(values.map { "(" + $0.serialize(&binds) + ")"}.joined(separator: ", "))
        if let upsert = self.upsert {
            sql.append(upsert.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}
