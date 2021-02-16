Scriptname nl_util_example extends quest

string store

import nl_util

Event OnInit()
    ; Get Associated esp
    string mod = GetFormModName(self)
    
    ; Insert three values under group
    store = InsertGroupVal(store, mod, 0x00023 as string)
    store = InsertGroupVal(store, mod, 0x1213112 as string)
    store = InsertGroupVal(store, mod, 0x121223 as string)
    
    ; Only allow insertion of unique values inside store
    if !HasVal(store, 0x00023 as string)
        ; Won't trigger
        store = InsertGroupVal(store, mod, 0x00023 as string)
    endif
    
    ; Only allow insertion of unique values inside groups
    if !HasGroupVal(store, mod, 0x00023 as string)
        ; Won't trigger
        store = InsertGroupVal(store, mod, 0x00023 as string)
    endif
    
    store = InsertGroupVal(store, "RandomGroup", "hey hey")
    
    ; Loop over all values
    string[] groups = GetGroups(store)
    string[] values
    int i = groups.Length
    
    while i > 0
        i -= 1
        values = GetGroupVals(groups[i])
        int j = values.Length
        
        while j > 0
            j -= 1
            Debug.Trace(values[j])
        endwhile
        
        ; Print group id
        Debug.Trace(GetFirstGroupID(groups[i]))
    endwhile
    
    ; Print all group ids
    groups = GetGroupIDs(store)
    i = groups.Length
    while i > 0
        i -= 1
        Debug.Trace(groups[i])
    endwhile
    
    ; Get values from specific group, and print the first one
    values = GetGroupVals(store, "RandomGroup")
    Debug.Trace(values[0])
    
    ; Delete entire group
    store = DelGroup(store, mod)
    
    ; Group will be deleted when the last remaining value is deleted
    store = DelGroupVal(store, "RandomGroup", "hey hey")
EndEvent