import Foundation

public struct DataFileManager {
    /// The first path of the directory.
    private let mainFolder = "DataFileManager"
    
    public init() {}

    /**
     Builds the main directory URL.
     */
    private var directoryURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let folderDirectoryURL = paths.first!.appendingPathComponent(mainFolder)
        return folderDirectoryURL
    }
    
    /**
     Gets directory URL.
     - Parameter createIfNeeded: if true, creates the directory.
     */
    private func directoryURL(createIfNeeded: Bool) -> URL? {
        if createIfNeeded {
            do {
              try FileManager.default.createDirectory(at: directoryURL,
                                                      withIntermediateDirectories: true,
                                                      attributes: nil)
            } catch {
                let description = "Couldn't create main directory \(error.localizedDescription)"
                print("Data File Manager directoryPath: \(description)")
                return nil
            }
        }
        return directoryURL
    }
    
    /**
     Gets the corresponding URL, using the folder received.
     - Parameters:
     - folder: The name of the directory consultated,
     - createIfNeeded: Bool value indicating whether the directory should be created if it doesn't exists.
     - returns: The URL corresponding to the path created. If createIfNeeded  is true, and failed to creates the directory, returns nil.
     */
    private func folderDirectoryURL(folder: String, createIfNeeded: Bool) -> URL? {
        guard let folderDirectoryURL = directoryURL(createIfNeeded: createIfNeeded)?.appendingPathComponent(folder, isDirectory: true) else {
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
     - id: The path component to add.
     - folder: The name of the directory consultated.
     - createIfNeeded: Bool value indicating whether the directory should be created if it doesn't exists.
     - returns: An optional URL, the corresponding URL if the consult was succesfull, and nil if it wasn't.
     - Note: If folder is nil, the id (path component) will be created (if needed) at directory path level.
     */
    private func dataDirectoryURL(id: String, folder: String? = nil, createIfNeeded: Bool) -> URL? {
        guard !id.isEmpty else { return nil }
        if let folder = folder {
            return folderDirectoryURL(folder: folder, createIfNeeded: createIfNeeded)?.appendingPathComponent(id)
        } else {
            return directoryURL(createIfNeeded: createIfNeeded)?.appendingPathComponent(id)
        }
    }
    
    /**
     Saves the received data in the corresponding path, using the folder and id passed.
     - Parameters:
     - data: The data to write.
     - id: The name under which the data should be written.
     - folder: The name of the directory where data should be written.
     - returns: An optional URL, the corresponding URL if the saving was succesfull, and nil if it wasn't.
     */
    public func write(data: Data?, id: String?, folder: String? = nil) -> URL? {
        guard let data = data, let id = id, let dataPath = dataDirectoryURL(id: id, folder: folder, createIfNeeded: true) else { return nil }
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
     Wites data located in originURL.
     - Parameters:
     - originURL: The local url where data it's currently located.
     - id: Name under which the data will be saved.
     - folder: Directory name where data should be saved, if nil is passed, the data will be saved wihout a folder.
     - removeFromOrigin: default value to true, if true removes data from originURL.
     - returns: URL where data was written.
     - Note: The URL returned just works per session.
     */
    public func write(originURL: URL?, id: String?, folder: String? = nil, removeFromOrigin: Bool = true) -> URL? {
        guard let url = originURL, let data = try? Data(contentsOf: url), let id = id, let dataURL = dataDirectoryURL(id: id, folder: folder, createIfNeeded: true) else { return nil }
        do {
            try data.write(to: dataURL)
            if removeFromOrigin {
                deleteData(at: url)
            }
        } catch {
            let description = "Couldn't write data from url with id: \(id) \(error.localizedDescription)"
            print("DataFileManager [Info]: \(description)")
        }
        return dataURL
    }

    /**
     Gets the data located if the folder, with the name passed.
     - Parameters:
     - folder: The folder where data should be.
     - id: The name of the data.
     - returns: nil if not data was found, or the data found.
     */
    public func loadData(id: String?, folder: String? = nil) -> Data? {
        guard let id = id, !id.isEmpty, let dataPath = dataDirectoryURL(id: id, folder: folder, createIfNeeded: false) else { return nil }
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
        guard let id = id, !id.isEmpty, let dataPath = dataDirectoryURL(id: id, folder: folder, createIfNeeded: false) else { return nil }
        guard (try? Data(contentsOf: dataPath)) != nil else {
            return nil
        }
        return dataPath
    }
    
    public func deleteAll() {
        if let mainURL = directoryURL(createIfNeeded: false), fileExists(path: mainURL.path) {
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
        guard let folderURL = folderDirectoryURL(folder: folder, createIfNeeded: false),
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
        guard let id = id, let dataURL = dataDirectoryURL(id: id, folder: folder, createIfNeeded: false), fileExists(path: dataURL.path) else { return }
        do {
            try FileManager.default.removeItem(at: dataURL)
        } catch {
            let description = "Failed to delete file with id: \(id). \(error.localizedDescription)"
            print("Image File Manager [Info]: \(description)")
        }
    }
    
    /**
     Deletes data at URL.
     */
    private func deleteData(at originURL: URL) {
        let path = originURL.path
        guard fileExists(path: path) else { return }
        do {
            try FileManager.default.removeItem(at: originURL)
        } catch {
            let description = "Failed to delete data in url passed. \(error.localizedDescription)"
            print("DataFileManager [Info]: \(description)")
        }
    }
    
    private func fileExists(path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }
}

