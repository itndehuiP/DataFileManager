import Foundation

public struct DataFileManager {
    /// The first path of the directory.
    private let mainFolder = "DataFileManager"
    
    /**
     Builds the main directory path.
     */
    private var directoryPath: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let folderDirectoryURL = paths.first!.appendingPathComponent(mainFolder)
        return folderDirectoryURL
    }
    
    /**
     Gets directory path URL.
     - Parameter createIfNeeded: if true, creates the directory.
     */
    private func directoryPath(createIfNeeded: Bool) -> URL? {
        if createIfNeeded {
            do {
              try FileManager.default.createDirectory(at: directoryPath,
                                                      withIntermediateDirectories: true,
                                                      attributes: nil)
            } catch {
                let description = "Couldn't create main directory \(error.localizedDescription)"
                print("Data File Manager directoryPath: \(description)")
                return nil
            }
        }
        return directoryPath
    }
    
    /**
     Gets the corresponding path, using the subFolder received.
     - Parameters:
     - subFolder: The name of the directory consultated,
     - createIfNeeded: Bool value indicating whether the directory should be created if it doesn't exists.
     - returns: The URL corresponding to the path created. If createIfNeeded  is true, and failed to creates the directory, returnns nil.
     */
    private func folderDirectoryPath(folder: String, createIfNeeded: Bool) -> URL? {
        guard let folderDirectoryURL = directoryPath(createIfNeeded: createIfNeeded)?.appendingPathComponent(folder, isDirectory: true) else {
            return nil
        }
        if createIfNeeded {
            do {
                try FileManager.default.createDirectory(at: folderDirectoryURL,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                let description = "Couldn't create subFolder directory \(error.localizedDescription)"
                print("Data File Manager subFolderDirectoryPath: \(description)")
                return nil
            }
        }
        return folderDirectoryURL
    }
    
    /**
     Gets the URL corresponding to tha path required.
     - Parameters:
     - folder: The name of the directory consultated.
     - id: The path component of the diretory consultated.
     - createIfNeeded: Bool value indicating whether the directory should be created if it doesn't exists.
     - returns: An optional URL, the corresponding URL if the consult was succesfull, and nil if it wasn't.
     - Note: If folder is nil, the id (path component) will be created (if needed) at directory path level.
     */
    private func dataDirectoryPath(id: String, folder: String? = nil, createIfNeeded: Bool) -> URL? {
        guard !id.isEmpty else { return nil }
        if let folder = folder {
            return folderDirectoryPath(folder: folder, createIfNeeded: createIfNeeded)?.appendingPathComponent(id)
        } else {
            return directoryPath(createIfNeeded: createIfNeeded)?.appendingPathComponent(id)
        }
    }
    
    /**
     Saves the received data in the corresponding path, using the folder and id passed.
     - Parameters:
     - data: The data to save.
     - folder: The name of the folder where data should be written.
     - id: The name under which the data should be written.
     - returns: An optional URL, the corresponding URL if the saving was succesfull, and nil if it wasn't.
     */
    public func write(data: Data?, id: String?, folder: String? = nil) -> URL? {
        guard let data = data, let id = id, let dataPath = dataDirectoryPath(id: id, folder: folder, createIfNeeded: true) else { return nil }
        do {
            try data.write(to: dataPath)
        } catch {
            let description = "Couldn't complete writing with id: \(id). \(error.localizedDescription)"
            print("Data File Manager [Info]: \(description)")
            return nil
        }
        return dataPath
    }

    /**
     Gets the data located if the folder, with the name passed.
     - Parameters:
     - folder: The folder where data should be.
     - id: The name of the data.
     - returns: nil if not data was found, or the data found.
     */
    public func loadData(id: String?, folder: String? = nil) -> Data? {
        guard let id = id, !id.isEmpty, let dataPath = dataDirectoryPath(id: id, folder: folder, createIfNeeded: false) else { return nil }
        return try? Data(contentsOf: dataPath)
    }
    
    /**
     Gets the data located if the folder, with the name passed .
     - Parameters:
     - folder: The folder where data should be.
     - id: The name of the data.
     - returns: the session URL, if data its located with the parameters, nil if its not.
     */
    public func getURLIfExists(id: String?, folder: String? = nil) -> URL? {
        guard let id = id, !id.isEmpty, let dataPath = dataDirectoryPath(id: id, folder: folder, createIfNeeded: false) else { return nil }
        guard (try? Data(contentsOf: dataPath)) != nil else {
            return nil
        }
        return dataPath
    }
    
    public func deleteAll() {
        if let mainURL = directoryPath(createIfNeeded: false), fileExists(path: mainURL.path) {
            do {
                try FileManager.default.removeItem(at: mainURL)
            } catch {
                let description = "Failed to delete main folder. \(error.localizedDescription)"
                print("Data File Manager [Info]: \(description)")
            }
        }
    }
    
    /**
     Deletes the directory with "folder" name.
     */
    public func delete(folder: String) {
        guard let folderURL = folderDirectoryPath(folder: folder, createIfNeeded: false),
              fileExists(path: folderURL.path) else { return }
        do {
            try FileManager.default.removeItem(at: folderURL)
        } catch {
            let description = "Failed to delete album folder: \(folder). \(error.localizedDescription)"
            print("Data File Manager [Info]: \(description)")
        }
    }
    
    /**
     Deletes data in folder with id.
     - folder: Directory where data will be searched.
     - id: The name under which the data its saved.
     */
    public func deleteData(id: String?, folder: String? = nil) {
        guard let id = id, let dataURL = dataDirectoryPath(id: id, folder: folder, createIfNeeded: false), fileExists(path: dataURL.path) else { return }
        do {
            try FileManager.default.removeItem(at: dataURL)
        } catch {
            let description = "Failed to delete file with id: \(id). \(error.localizedDescription)"
            print("Image File Manager [Info]: \(description)")
        }
    }
    
    private func fileExists(path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }
}

