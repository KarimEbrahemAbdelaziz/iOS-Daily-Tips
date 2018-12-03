// The iterator pattern is used to provide a standard interface 
// for traversing a collection of items in an aggregate object 
// without the need to understand its underlying structure.

struct Novella {
    let name: String
}

struct Novellas {
    let novellas: [Novella]
}

struct NovellasIterator: IteratorProtocol {

    private var current = 0
    private let novellas: [Novella]

    init(novellas: [Novella]) {
        self.novellas = novellas
    }

    mutating func next() -> Novella? {
        defer { current += 1 }
        return novellas.count > current ? novellas[current] : nil
    }
}

extension Novellas: Sequence {
    func makeIterator() -> NovellasIterator {
        return NovellasIterator(novellas: novellas)
    }
}

// Usage
let greatNovellas = Novellas(novellas: [Novella(name: "The Mist 1"),
                                        Novella(name: "The Mist 2"),
                                        Novella(name: "The Mist 3"),
                                        Novella(name: "The Mist 4")] )

for novella in greatNovellas {
    print("I've read: \(novella)")
}