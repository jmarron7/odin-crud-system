package main

import "core:fmt"

import "crudsys"

main :: proc() {
    // Initialize the CRUD system
    fmt.println("CRUD System Example")
    crud := crudsys.CRUDSystem{}

    // Create some entities
    crudsys.create(&crud, "First Entity")
    crudsys.create(&crud, "Second Entity")
    crudsys.create(&crud, "Third Entity")

    // Read all entities
    entities := crudsys.read_all(&crud)
    for entity in entities {
        fmt.println("{\n\tEntity ID:", entity.id, "\n\tData:", entity.data, "\n}")
    }
    fmt.println("------------------")

    // Update an entity
    crudsys.update(&crud, entities[0].id, "Updated Entity")

    // Delete an entity
    crudsys.delete_entity(&crud, entities[1].id)

    // Read all entities after update and delete
    entities = crudsys.read_all(&crud)
    for entity in entities {
        fmt.println("{\n\tEntity ID:", entity.id, "\n\tData:", entity.data, "\n}")
    }
    fmt.println("------------------")

    // Undo the last action
    crudsys.undo(&crud)

    // Read all entities after undo
    entities = crudsys.read_all(&crud)
    for entity in entities {
        fmt.println("{\n\tEntity ID:", entity.id, "\n\tData:", entity.data, "\n}")
    }
    fmt.println("------------------")
}