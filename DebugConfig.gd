# Central debug configuration
# Toggle verbose debug printing without removing code.
class_name DebugConfig
extends Object

# Master switch for verbose logging (save/load/firebase quests etc.)
const VERBOSE := false

# Optional granular flags (set to true temporarily when investigating):
const LOG_SAVE_LOAD := false
const LOG_FIREBASE := false
const LOG_QUESTS := false

# Autosave configuration
# Set AUTOSAVE_ENABLED true to turn on periodic saving.
const AUTOSAVE_ENABLED := true
# Default autosave interval in seconds.
const AUTOSAVE_INTERVAL_SEC := 60
