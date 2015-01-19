//
//  DataAccessSqlite.swift
//  maintainbike
//
//  Created by Fahim Farook on 11/6/14.
//  Updated by zlywq on 14/12/11.
//  Copyright (c) 2014年 mbike. All rights reserved.
//

import Foundation

typealias DictionaryStringToAny = [String:AnyObject] //[String:Any]
typealias ArrayWithAny = Array<AnyObject> //Array<Any>
typealias ArrayWithAnyQ = Array<AnyObject?>//Array<Any?>

struct Util{
    static func join(ary:ArrayWithAny?, seperator:String) -> String {
        return join(ary, seperator: seperator, needSepBothSide: false)
    }
    static func join(ary:ArrayWithAny?, seperator:String, needSepBothSide:Bool) -> String {
        var s = "";
        var cnt : Int = ary==nil ? 0 : ary!.count
        for(var i=0; i<cnt; i++){
            if i == 0 {
                s += "\(ary![i])"
            }else{
                s += "\(seperator)\(ary![i])"
            }
        }
        if (needSepBothSide){
            s = "\(seperator)\(s)\(seperator)"
        }
        return s
    }
}

private let SQLITE_STATIC = sqlite3_destructor_type(COpaquePointer(bitPattern:0))
private let SQLITE_TRANSIENT = sqlite3_destructor_type(COpaquePointer(bitPattern:-1))

//let SQLITE_LONG_my = SQLITE_NULL + 100





//-------------------------------------------------------

typealias SQLRow = DBRow

class DBRow {
    var columnNames : Array<String>?
    var columnTypes : Array<CInt>?
    var columnNameToIndex : Dictionary<String,Int>?
    //        var data = Dictionary<String, Any>()
    var values : ArrayWithAnyQ? = nil
    
    func setColumnNamesAndTypes(columnNames : Array<String>, columnTypes : Array<CInt>, columnNameToIndex : Dictionary<String,Int>?) -> Dictionary<String,Int>?{
        self.columnNames = columnNames
        self.columnTypes = columnTypes
        self.columnNameToIndex = columnNameToIndex
        if (self.columnNameToIndex == nil){
            self.columnNameToIndex = [:]
            for(var i=0; i<columnNames.count; i++){
                self.columnNameToIndex![columnNames[i]] = i
            }
        }
        values = Array(count: columnNames.count, repeatedValue: nil)
        
        return self.columnNameToIndex
    }
    
    func getColumnName(idx:Int)->String{
        return columnNames![idx]
    }
    func getColumnNameIndex(columnName:String)->Int{
        var idx : Int! = columnNameToIndex![columnName]
        return idx
    }
    func getColumnType(idx:Int)->CInt{
        return columnTypes![idx]
    }
    
    func getColumnType(columnName:String)->CInt{
        var idx = getColumnNameIndex(columnName)
        return columnTypes![idx]
    }
    subscript(idx:Int) ->AnyObject? {
        get{
            return values![idx]
        }
        set(newVal){
            values![idx] = newVal
        }
    }
    subscript(key: String) -> AnyObject? {
        get {
            var idx = getColumnNameIndex(key)
            return self[idx]
        }
        set(newVal) {
            var idx = getColumnNameIndex(key)
            self[idx] = newVal
        }
    }
    
    func asDictionary() -> DictionaryStringToAny{
        var dict : DictionaryStringToAny = [:]
        if (columnNames != nil){
            for(var i=0; i<columnNames!.count; i++){
                var val: AnyObject? = values![i]
                if (val != nil){
                    dict[columnNames![i]] = val!
                }
            }
        }
        return dict
    }
    
    func cellValIsNil(idx:Int) -> Bool{
        var colType = columnTypes![idx]
        var value : AnyObject? = values![idx]
        var r = (value == nil)
        return r
    }
    func cellValIsNil(colName:String)->Bool {
        var idx = getColumnNameIndex(colName)
        return cellValIsNil(idx)
    }
    
    func cellValStr(idx:Int)->String{
        var colType = columnTypes![idx]
        var value1 : AnyObject? = values![idx]
        if let value: AnyObject = value1{
            switch (colType) {
            case SQLITE_INTEGER, SQLITE_FLOAT:
                return "\(value)"
            case SQLITE_TEXT:
                return value as String
            case SQLITE_BLOB:
                if let str = NSString(data:value as NSData, encoding:NSUTF8StringEncoding) {
                    return str
                } else {
                    return ""
                }
            case SQLITE_NULL:
                return ""
            default:
                return "\(value)"
            }
        }else{
            return ""
        }
    }
    func cellValStr(colName:String)->String{
        var idx = getColumnNameIndex(colName)
        return cellValStr(idx)
    }
    
    func cellValInt(idx:Int)->Int{
        var colType = columnTypes![idx]
        var value1 : AnyObject? = values![idx]
        if let value: AnyObject = value1{
            switch (colType) {
            case SQLITE_INTEGER:
                return value as Int
            case SQLITE_FLOAT:
                return Int(value as Double)
            case SQLITE_TEXT:
                let str = value as NSString
                return str.integerValue
            case SQLITE_BLOB:
                if let str = NSString(data:value as NSData, encoding:NSUTF8StringEncoding) {
                    return str.integerValue
                } else {
                    return 0
                }
            case SQLITE_NULL:
                return 0
            default:
                return 0
            }
        }else{
            return 0
        }
    }
    func cellValInt(colName:String)->Int {
        var idx = getColumnNameIndex(colName)
        return cellValInt(idx)
    }
    
    
    
    
    func cellValInt64(idx:Int)->Int64{
        var colType = columnTypes![idx]
        var value1 : AnyObject? = values![idx]
        if let value: AnyObject = value1{
            var colType = columnTypes![idx]
            var value : AnyObject? = values![idx]
            //            NSLog("cellValInt64 enter idx=\(idx), colType=\(colType), value=\(value)")
            switch (colType) {
            case SQLITE_INTEGER:
//                let lval = value as? Int64
//                //                NSLog("cellValInt64 idx=\(idx), lval=\(lval)")
//                if (lval != nil){
//                    //                    NSLog("cellValInt64 idx=\(idx), lval != nil")
//                    return lval!
//                }else{
//                    //                    NSLog("cellValInt64 idx=\(idx), lval == nil")
//                    let ival = value as? Int
//                    return Int64(ival!)
//                }
                let dval = value as? Double
                if (dval != nil){
                    return Int64(dval!)
                }else{
                    let ival = value as? Int
                    return Int64(ival!)
                }
            case SQLITE_FLOAT:
                return Int64(value as Double)
            case SQLITE_TEXT:
                let str = value as NSString
                return str.longLongValue
            case SQLITE_BLOB:
                if let str = NSString(data:value as NSData, encoding:NSUTF8StringEncoding) {
                    return str.longLongValue
                } else {
                    return 0
                }
            case SQLITE_NULL:
                return 0
            default:
                return 0
            }
        }else{
            return 0
        }
    }
    func cellValInt64(colName:String)->Int64 {
        var idx = getColumnNameIndex(colName)
        NSLog("cellValInt64 idx=\(idx), colName=\(colName)")
        return cellValInt64(idx)
    }
    
    
    
    func cellValDouble(idx:Int)->Double{
        var colType = columnTypes![idx]
        var value1 : AnyObject? = values![idx]
        if let value: AnyObject = value1{
            var colType = columnTypes![idx]
            var value : AnyObject? = values![idx]
            switch (colType) {
            case SQLITE_INTEGER:
//                return Double(value as Int)
                let dval = value as? Double
                if (dval != nil){
                    return dval!
                }else{
                    let ival = value as? Int
                    return Double(ival!)
                }
            case SQLITE_FLOAT:
                return value as Double
            case SQLITE_TEXT:
                let str = value as NSString
                return str.doubleValue
            case SQLITE_BLOB:
                if let str = NSString(data:value as NSData, encoding:NSUTF8StringEncoding) {
                    return str.doubleValue
                } else {
                    return 0.0
                }
            case SQLITE_NULL:
                return 0.0
            default:
                return 0.0
            }
        }else{
            return 0.0
        }
    }
    func cellValDouble(colName:String)->Double {
        var idx = getColumnNameIndex(colName)
        return cellValDouble(idx)
    }
    
    func cellValData(idx:Int)->NSData?{
        var colType = columnTypes![idx]
        var value1 : AnyObject? = values![idx]
        if let value: AnyObject = value1{
            var colType = columnTypes![idx]
            var value : AnyObject? = values![idx]
            switch (colType) {
            case SQLITE_INTEGER, SQLITE_FLOAT:
                let str = "\(value)" as NSString
                return str.dataUsingEncoding(NSUTF8StringEncoding)
            case SQLITE_TEXT:
                let str = value as NSString
                return str.dataUsingEncoding(NSUTF8StringEncoding)
            case SQLITE_BLOB:
                return value as? NSData
            case SQLITE_NULL:
                return nil
            default:
                return nil
            }
        }else{
            return nil
        }
    }
    func cellValData(colName:String)->NSData? {
        var idx = getColumnNameIndex(colName)
        return cellValData(idx)
    }
}



class DASqlite{
    let mLogEnabled = true
    
    var rawdb:COpaquePointer = nil
    
    var inTransaction : Bool = false
    
    var queue:dispatch_queue_t = dispatch_queue_create(StatConst.QUEUE_LABLE, nil)
    
    struct StatConst {
        static let DB_NAME = "db.dat"
        
        static let QUEUE_LABLE = "SQLiteDB"
        
        static var instance:DASqlite? = nil
        static var dispatch_once_token:dispatch_once_t = 0
        
        // Column types - http://www.sqlite.org/datatype3.html (section 2.2 table column 1)
        static let blobTypes = ["BINARY", "BLOB", "VARBINARY"]
        static let charTypes = ["CHAR", "CHARACTER", "CLOB", "NATIONAL VARYING CHARACTER", "NATIVE CHARACTER", "NCHAR", "NVARCHAR", "TEXT", "VARCHAR", "VARIANT", "VARYING CHARACTER"]
        static let dateTypes = ["DATE", "DATETIME", "TIME", "TIMESTAMP"]
        static let intTypes  = ["BIGINT", "BIT", "BOOL", "BOOLEAN", "INT", "INT2", "INT8", "INTEGER", "MEDIUMINT", "SMALLINT", "TINYINT"]
        static let nullTypes = ["NULL"]
        static let realTypes = ["DECIMAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT", "NUMERIC", "REAL"]
        
        static func getDBPath()->String{
            let docDir:AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let dbName:String = String.fromCString(StatConst.DB_NAME)!
            let path = docDir.stringByAppendingPathComponent(dbName)
            NSLog("SQLiteDB getDBPath ret:\(path)")
            return path
        }
        
        static func getSqlFilePath() -> String{
            let sqlFilePath = NSBundle.mainBundle().pathForResource("init_localdb", ofType: "sql")!
            return sqlFilePath
        }
        static func getSqlFileContent() -> String{
            var sqlFilePath:NSString = StatConst.getSqlFilePath()
            var fileContent:NSString! = NSString(contentsOfFile: sqlFilePath, encoding: NSUTF8StringEncoding, error: nil)
            return fileContent
        }
    }
    
    class func singleton() -> DASqlite! {
        dispatch_once(&StatConst.dispatch_once_token) {
            StatConst.instance = self()
        }
        return StatConst.instance!
    }
    
    
    
    required init(path:String) {
        myInit(path)
    }
    required convenience init(){
        let path = StatConst.getDBPath()
        self.init(path: path)
    }
    
    
    func myInit(path:NSString){
        let defFileManager : NSFileManager = NSFileManager.defaultManager()
        let fileExists = defFileManager.fileExistsAtPath(path)
        let cpath = path.cStringUsingEncoding(NSUTF8StringEncoding)
        NSLog("SQLiteDB cpath=\(cpath), path=\(path)")
        let openRet = sqlite3_open(cpath, &rawdb)
        if openRet != SQLITE_OK {
            assert(false, "sqlite3_open FAILED")
            sqlite3_close(rawdb)
        }
        if (!fileExists){
            myInitDBSchema()
        }
        
    }
    func myInitDBSchema(){
        var fileContent:NSString = StatConst.getSqlFileContent()
        var sitemAry = fileContent.componentsSeparatedByString(";;;") as [NSString]
        for(var i=0; i<sitemAry.count; i++){
            var sitem = sitemAry[i]
            var s2 = sitem.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if (s2.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0){
                self.execute(s2, parameters: nil)
            }
        }
        
    }
    
    deinit {
        closeDatabase()
    }
    private func closeDatabase() {
        if rawdb != nil {
            sqlite3_close(rawdb)
            rawdb = nil
        }
    }
    //------------------------------------------------------------------------------------------
    
    func beginTransaction() -> CInt{
        assert(!inTransaction)
        inTransaction = true
        return execute("begin exclusive transaction", parameters: nil)
    }
    
    func rollbackTransaction() -> CInt {
        inTransaction = false
        return execute("rollback transaction", parameters: nil)
    }
    
    func commitTransaction() -> CInt {
        inTransaction = false
        return execute("commit transaction", parameters: nil)
    }
    
    
    
    //------------------------------------------------------------------------------------------
    //improve from SQLiteDB
    
    
    
    
    
    private func prepare(sql:String, params:ArrayWithAny?)->COpaquePointer {
        var stmt:COpaquePointer = nil
        var cSql = sql.cStringUsingEncoding(NSUTF8StringEncoding)
        // Prepare
        let result = sqlite3_prepare_v2(self.rawdb, cSql!, -1, &stmt, nil)
        if result != SQLITE_OK {
            sqlite3_finalize(stmt)
            if let error = String.fromCString(sqlite3_errmsg(self.rawdb)) {
                let msg = "SQLiteDB - failed to prepare SQL: \(sql), Error: \(error)"
                println(msg)
                //				CLSLogv(msg, getVaList([]))
            }
            return nil
        }
        // Bind parameters, if any
        if params != nil && params?.count > 0 {
            // Validate parameters
            let cntParams = sqlite3_bind_parameter_count(stmt)
            let cnt = CInt(params!.count)
            assert( cntParams==cnt, "SQLiteDB - failed to bind parameters, counts did not match. SQL: \(sql), Parameters: \(params)")
            var flag:CInt = 0
            // Text & BLOB values passed to a C-API do not work correctly if they are not marked as transient.
            for ndx in 1...cnt {
                //				println("Binding: \(params![ndx-1]) at Index: \(ndx)")
                // Check for data types
                if let txt = params![ndx-1] as? String {
                    flag = sqlite3_bind_text(stmt, CInt(ndx), txt, -1, SQLITE_TRANSIENT)
                } else if let data = params![ndx-1] as? NSData {
                    flag = sqlite3_bind_blob(stmt, CInt(ndx), data.bytes, CInt(data.length), SQLITE_TRANSIENT)
                } else if let val = params![ndx-1] as? Double {
                    flag = sqlite3_bind_double(stmt, CInt(ndx), CDouble(val))
//                } else if let val = params![ndx-1] as? Int64 {
//                    flag = sqlite3_bind_int64(stmt, CInt(ndx), sqlite3_int64(Int64(val)))
                } else if let val = params![ndx-1] as? Int {
                    flag = sqlite3_bind_int(stmt, CInt(ndx), CInt(val))
                } else {
                    flag = sqlite3_bind_null(stmt, CInt(ndx))
                }
                // Check for errors
                if flag != SQLITE_OK {
                    sqlite3_finalize(stmt)
                    if let error = String.fromCString(sqlite3_errmsg(self.rawdb)) {
                        var paramsStr = Util.join(params, seperator: ",")
                        let msg = "SQLiteDB - failed to bind for SQL: \(sql), Parameters: \(paramsStr), Index: \(ndx) Error: \(error)"
                        println(msg)
                        //						CLSLogv(msg, getVaList([]))
                    }
                    return nil
                }
            }
        }
        return stmt
    }
    
    func execute(sql:String, parameters:ArrayWithAny?=nil)->CInt {
        var result:CInt = 0
        dispatch_sync(queue) {
            let stmt = self.prepare(sql, params:parameters)
            if stmt != nil {
                result = self.execute(stmt, sql:sql)
            }
        }
        return result
    }
    // Private method which handles the actual execution of an SQL statement
    private func execute(stmt:COpaquePointer, sql:String)->CInt {
        // Step
        var result = sqlite3_step(stmt)
        if result != SQLITE_OK && result != SQLITE_DONE {
            sqlite3_finalize(stmt)
            if let err = String.fromCString(sqlite3_errmsg(self.rawdb)) {
                let msg = "SQLiteDB - failed to execute SQL: \(sql), Error: \(err)"
                println(msg)
                //				CLSLogv(msg, getVaList([]))
            }
            return result
        }
        // Is this an insert
        let upp = sql.uppercaseString
        if upp.hasPrefix("INSERT ") {
            // Known limitations: http://www.sqlite.org/c3ref/last_insert_rowid.html
            let rid = sqlite3_last_insert_rowid(self.rawdb)
            result = CInt(rid)
        } else if upp.hasPrefix("DELETE") || upp.hasPrefix("UPDATE") {
            var cnt = sqlite3_changes(self.rawdb)
            if cnt == 0 {
                cnt++
            }
            result = CInt(cnt)
        } else {
            result = 1
        }
        // Finalize
        sqlite3_finalize(stmt)
        return result
    }
    
    
    func query(sql:String, parameters:ArrayWithAny?=nil)->[DBRow] {
        var rows = [DBRow]()
        dispatch_sync(queue) {
            let stmt = self.prepare(sql, params:parameters)
            if stmt != nil {
                rows = self.query(stmt, sql:sql)
            }
        }
        return rows
    }
    // Private method which handles the actual execution of an SQL query
    private func query(stmt:COpaquePointer, sql:String)->Array<DBRow> {
        var rows = Array<DBRow>()
        var fetchColumnInfo = true
        var columnCount:CInt = 0
        
        var columnNames = [String]()
        var columnTypes = [CInt]()
        var columnNameToIndex : Dictionary<String,Int>? = nil
        
        //NSLog("DASqlite query before sqlite3_step(stmt)")
        var result = sqlite3_step(stmt)
        //NSLog("DASqlite query after sqlite3_step(stmt)")
        while result == SQLITE_ROW {
            // Should we get column info?
            if fetchColumnInfo {
                columnCount = sqlite3_column_count(stmt)
                for index in 0..<columnCount {
                    let name = sqlite3_column_name(stmt, index)
                    columnNames.append(String.fromCString(name)!)
                    columnTypes.append(self.getColumnType(index, stmt:stmt))
                }
                fetchColumnInfo = false
            }
            // Get row data for each column
            var row = DBRow()
            columnNameToIndex = row.setColumnNamesAndTypes(columnNames, columnTypes: columnTypes, columnNameToIndex: columnNameToIndex)
            for index in 0..<columnCount {
                var idx = Int(index)
                let key = columnNames[idx]
                let type = columnTypes[idx]
                //                NSLog("query in for{} index=\(idx), key=\(key)")
                if let val: AnyObject = self.getColumnValue(index, type:type, stmt:stmt) {
                    //                    NSLog("query in for{} index=\(idx), key=\(key), val=\(val)")
                    row[idx] = val
                }else{
                    row[idx] = nil
                }
            }
            rows.append(row)
            // Next row
            result = sqlite3_step(stmt)
        }
        //NSLog("DASqlite query before sqlite3_finalize(stmt)")
        sqlite3_finalize(stmt)
        //NSLog("DASqlite query after sqlite3_finalize(stmt)")
        return rows
    }
    
    
    
    // Get column type
    private func getColumnType(index:CInt, stmt:COpaquePointer)->CInt {
        var type:CInt = 0
        
        // Determine type of column - http://www.sqlite.org/c3ref/c_blob.html
        let buf = sqlite3_column_decltype(stmt, CInt(index))
        //        println("getColumnType sqlite3_column_decltype:\(buf)")
        if buf != nil {
            var tmp = String.fromCString(buf)!.uppercaseString
            // Remove brackets
            let pos = tmp.positionOf("(")
            if pos > 0 {
                tmp = tmp.subStringTo(pos)
            }
            // Remove unsigned?
            // Remove spaces
            // Is the data type in any of the pre-set values?
            //			println("SQLiteDB - Cleaned up column type: \(tmp)")
            var retType : CInt = SQLITE_TEXT
            if contains(StatConst.intTypes, tmp) {
                retType = SQLITE_INTEGER
            }else if contains(StatConst.realTypes, tmp) {
                retType = SQLITE_FLOAT
            }else if contains(StatConst.charTypes, tmp) {
                retType = SQLITE_TEXT
            }else if contains(StatConst.blobTypes, tmp) {
                retType = SQLITE_BLOB
            }else if contains(StatConst.nullTypes, tmp) {
                retType = SQLITE_NULL
            }
            //            NSLog("getColumnType buf=\(tmp) index=\(Int(index)) retType=\(retType)")
            return retType
        } else {
            // For expressions and sub-queries
            type = sqlite3_column_type(stmt, index)
            //            NSLog("getColumnType buf=nil index=\(Int(index)) type=\(type)")
            return type
        }
    }
    
    
    
    
    private func getColumnValue(index:CInt, type:CInt, stmt:COpaquePointer)->AnyObject? {
        // Integer
        if type == SQLITE_INTEGER {
            //            NSLog("getColumnValue type == SQLITE_INTEGER index=\(index)")
            //            let val = sqlite3_column_int(stmt, index)
            //            return Int(val)
            let val = sqlite3_column_int64(stmt, index)
            //            NSLog("getColumnValue type == SQLITE_INTEGER index=\(index) sqlite3_column_int64 ret:\(val)")
            let lval : Int64 = val
            //            NSLog("getColumnValue type == SQLITE_INTEGER index=\(index) lval=\(lval)")
            if lval > Int64(Int.max) || lval < Int64(Int.min) {
                // AnyObject不能容纳Int64，但Any可以，就不必转换为NSNumber了
                //                return NSNumber(longLong: lval)
                return Double(lval)
            }else{
                let ival : Int = Int(lval)
                //NSLog("getColumnValue type == SQLITE_INTEGER ival=\(ival)")
                return ival
            }
        }
        // Float
        if type == SQLITE_FLOAT {
            //            NSLog("getColumnValue type == SQLITE_FLOAT index=\(index)")
            let val = sqlite3_column_double(stmt, index)
            return Double(val)
        }
        // Text - handled by default handler at end
        // Blob
        if type == SQLITE_BLOB {
            //            NSLog("getColumnValue type == SQLITE_BLOB index=\(index)")
            let data = sqlite3_column_blob(stmt, index)
            let size = sqlite3_column_bytes(stmt, index)
            let val = NSData(bytes:data, length: Int(size))
            return val
        }
        // Null
        if type == SQLITE_NULL {
            //            NSLog("getColumnValue type == SQLITE_NULL index=\(index)")
            return nil
        }
        
        //        NSLog("getColumnValue type == OTHER as string, index=\(index)")
        // If nothing works, return a string representation
        let buf = UnsafePointer<Int8>(sqlite3_column_text(stmt, index))
        let val = String.fromCString(buf)
        //		println("SQLiteDB - Got value: \(val)")
        return val
    }
    
    
    
    
    
    //-------------------------------------------------
    
    
    class func generateHuodongholderPartForIn(cnt:Int) -> String{
        var ary : [String] = Array<String>(count: cnt, repeatedValue: "?")
        var s = Util.join(ary, seperator: ",")
        return s
    }
    class func generateInCondition_argMode(field:String , valAry:[String]? )->String{
        var sCond = ""
        var cnt : Int = valAry==nil ? 0 : valAry!.count
        if (cnt == 0){
            sCond = ""
        }else if(cnt == 1){
            sCond = "\(field) =?"
        }else{
            var HuodongholderPart = generateHuodongholderPartForIn(cnt);
            sCond = "\(field) in (\(HuodongholderPart))"
        }
        return sCond
    }
    class func getColumnFromRows(rows:[SQLRow], colIndex:Int) -> ArrayWithAnyQ{
        var ary : ArrayWithAnyQ = []
        for(var i=0; i<rows.count; i++){
            var obj: AnyObject? = rows[i][colIndex]
            ary.append(obj)
        }
        return ary
    }
    class func getColumnFromRowsWithNoNilVal(rows:[SQLRow], colIndex:Int) -> ArrayWithAny{
        var ary : ArrayWithAny = []
        for(var i=0; i<rows.count; i++){
            var obj: AnyObject? = rows[i][colIndex]
            ary.append(obj!)
        }
        return ary
    }

    
    
    //-------------------------------------------------
    
    
    func insertTable1(name:String ,age:Int ,price:Double) -> CInt
    {
        var sql = "INSERT INTO Table1 (name, age, price) VALUES (?,?,?);"
        var params : ArrayWithAny = [name, age, price]
        return execute(sql, parameters: params)
    }
    func deleteTable1(name:String) -> CInt{
        var sql = "DELETE FROM Table1 WHERE name=? ";
        var params : ArrayWithAny = [name]
        return execute(sql, parameters: params)
    }
    func getTable1(age:Int) -> [SQLRow]{
        var query = "SELECT * FROM Table1  WHERE age=?";
        var params : ArrayWithAny = [age]
        return self.query(query, parameters: params)
    }

    
    
    
    
    
    
    
    
    
}

