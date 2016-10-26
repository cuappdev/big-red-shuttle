func system() -> System {
    return System.system
}

class System {
        
    static let system: System = {
        return System()
    }()
    
    init() {
        
    }
}
