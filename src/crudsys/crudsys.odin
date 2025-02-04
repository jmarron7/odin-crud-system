package crudsys

import "base:runtime"
import "core:crypto"
import "core:fmt"
import "core:sync"
import "core:encoding/uuid"

// Entity struct for our data
Entity :: struct {
    id:     string,
    data:   string,
}

// CRUD System that holds our entities and history
CRUDSystem :: struct {
    entities:   map[string]Entity,
    history:    [dynamic]UndoAction,
    mutex:      sync.Mutex,
}

// Action_Type enum for different CRUD actions
Action_Type :: enum {
    Create,
    Read,
    Update,
    Delete,
}

// UndoAction struct to keep track of actions
UndoAction :: struct {
    action_type:    Action_Type,
    entity:         Entity,
}

// Create new entity
create :: proc(self: ^CRUDSystem, data: string) {
    sync.mutex_lock(&self.mutex)
    defer sync.mutex_unlock(&self.mutex)
    
    context.random_generator = crypto.random_generator()

    id := uuid.to_string(uuid.generate_v4())
    if id in self.entities {
        fmt.println("Entity with this ID already exists.")
        return
    }

    entity := Entity{id, data}
    self.entities[id] = entity
    runtime.append_elem(&self.history, UndoAction{.Create, entity})
}

// Read an entity by ID
read_entity :: proc(self: ^CRUDSystem, id: string) -> (^Entity, bool) {
    sync.mutex_lock(&self.mutex)
    defer sync.mutex_unlock(&self.mutex)

    if id in self.entities {
        return &self.entities[id], true
    }
    return nil, false
}

// Read all entities
read_all :: proc(self: ^CRUDSystem) -> []Entity {
    sync.mutex_lock(&self.mutex)
    defer sync.mutex_unlock(&self.mutex)

    entities: [dynamic]Entity
    for _, entity in self.entities {
        append(&entities, entity)
    }
    return entities[:]
}

// Update an entity by ID
update :: proc(self: ^CRUDSystem, id: string, new_data: string) {
    sync.mutex_lock(&self.mutex)
    defer sync.mutex_unlock(&self.mutex)

    if !(id in self.entities) {
        fmt.println("Entity not found.")
        return
    }

    old_entity := self.entities[id]
    old_entity.data = new_data
    self.entities[id] = old_entity
    runtime.append_elem(&self.history, UndoAction{.Update, old_entity})
}

// Delete an entity by ID
delete_entity :: proc(self: ^CRUDSystem, id: string) {
    sync.mutex_lock(&self.mutex)
    defer sync.mutex_unlock(&self.mutex)

    if !(id in self.entities) {
        fmt.println("Entity not found.")
        return
    }

    entity := self.entities[id]
    delete_key(&self.entities, id)
    runtime.append_elem(&self.history, UndoAction{.Delete, entity})
}

// Undo the last action
undo :: proc(self: ^CRUDSystem) {
    sync.mutex_lock(&self.mutex)
    defer sync.mutex_unlock(&self.mutex)

    if len(self.history) == 0 {
        fmt.println("No actions to undo.")
        return
    }

    last_action := self.history[len(self.history) - 1]
    #partial switch last_action.action_type {
    case .Create:
            delete_key(&self.entities, last_action.entity.id)
    case .Update:
            self.entities[last_action.entity.id] = last_action.entity
    case .Delete:
            self.entities[last_action.entity.id] = last_action.entity
    }
    unordered_remove(&self.history, len(self.history) - 1)
}