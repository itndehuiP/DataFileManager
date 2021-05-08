import XCTest
@testable import DataFileManager

struct DataMock: Codable {
    var name: String
    var value: Int
}


final class DataFileManagerTests: XCTestCase {
    let dataManager = DataFileManager()
    
    func testSaveWithoutFolder() {
        let mock = DataMock(name: "TestA", value: 0)
        let data = try? JSONEncoder().encode(mock)
        XCTAssertNotNil(data)
        let url = dataManager.write(data: data, id: "TestA")
        XCTAssertNotNil(url)
    }
    
    func testLoadWithoutFolder() {
        let mock = DataMock(name: "TestB", value: 0)
        let data = try? JSONEncoder().encode(mock)
        let mockQ = try! JSONDecoder().decode(DataMock.self, from: data!)
        XCTAssertEqual(mockQ.name, "TestB")
        XCTAssertNotNil(data)
        let url = dataManager.write(data: data, id: "TestB")
        XCTAssertNotNil(url)
        let dataF = dataManager.loadData(id: "TestB")
        XCTAssertNotNil(dataF)
        let mockR = try! JSONDecoder().decode(DataMock.self, from: dataF!)
        XCTAssertEqual(mockR.name, "TestB")
    }
    
    func testDeleteWithoutFolder() {
        let mock = DataMock(name: "TestC", value: 0)
        let data = try? JSONEncoder().encode(mock)
        XCTAssertNotNil(data)
        let url = dataManager.write(data: data, id: "TestC")
        XCTAssertNotNil(url)
        let dataF = dataManager.loadData(id: "TestC")
        XCTAssertNotNil(dataF)
        dataManager.deleteData(id: "TestC")
        let dataA = dataManager.loadData(id: "TestC")
        XCTAssertNil(dataA)
    }
    
    func testSaveWithFolder() {
        let mock = DataMock(name: "TestFolder", value: 0)
        let data = try? JSONEncoder().encode(mock)
        XCTAssertNotNil(data)
        let url = dataManager.write(data: data, id: "Test", folder: "TestFolder")
        XCTAssertNotNil(url)
    }
    
    func testLoadWithFolder() {
        let mock = DataMock(name: "Test", value: 0)
        let data = try? JSONEncoder().encode(mock)
        XCTAssertNotNil(data)
        let url = dataManager.write(data: data, id: "Test", folder: "FolderA")
        XCTAssertNotNil(url)
        let dataLoaded = dataManager.loadData(id: "Test", folder: "FolderA")
        XCTAssertNotNil(dataLoaded)
    }
    
    func testDeleteWithFolder() {
        let mock = DataMock(name: "Test", value: 0)
        let data = try? JSONEncoder().encode(mock)
        XCTAssertNotNil(data)
        let url = dataManager.write(data: data, id: "Test", folder: "FolderB")
        XCTAssertNotNil(url)
        var dataLoaded = dataManager.loadData(id: "Test", folder: "FolderB")
        XCTAssertNotNil(dataLoaded)
        dataManager.deleteData(id: "Test", folder: "FolderB")
        dataLoaded = dataManager.loadData(id: "Test", folder: "FolderB")
        XCTAssertNil(dataLoaded)
    }
    
    func testDeleteAlbumFolder() {
        let mock = DataMock(name: "Test", value: 0)
        let data = try? JSONEncoder().encode(mock)
        XCTAssertNotNil(data)
        let url = dataManager.write(data: data, id: "Test", folder: "FolderC")
        XCTAssertNotNil(url)
        var dataLoaded = dataManager.loadData(id: "Test", folder: "FolderC")
        XCTAssertNotNil(dataLoaded)
        dataManager.delete(folder: "FolderC")
        dataLoaded = dataManager.loadData(id: "Test", folder: "FolderC")
        XCTAssertNil(dataLoaded)
    } 

    static var allTests = [
        ("testSaveWithoutFolder", testSaveWithoutFolder),
    ]
}
