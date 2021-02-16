Scriptname nl_util

;@author NeverLost
;@version 1.0.0

import Math
import Game
import StringUtil

;----------\
; DANGEROUS \
;--------------------------------------------------------
; I RECOMMEND NOT USING THESE
; IF YOU DO NOT KNOW WHAT YOU ARE DOING
; NOT SAFE!

;@param int i start index
;@param int j start index + length. If j is -1, it is interpreted to be the end of the store
;@return string store with span removed
string function DelSpan(string store, int i, int j) global
	if j == -1
	; Nothing left
		if i == 0
			return ""
		endif
	
	; End
		return Substring(store, 0, i)
	; Start
	elseif i == 0
		return SubString(store, j)
	; Middle
	else
		return SubString(store, 0, i) + SubString(store, j)
	endif
endfunction

;@param int i start index
;@param int j start index + length. If j is -1, it is interpreted to be the end of the store
;@return string span
string function GetSpan(string store, int i, int j) global
	if j == -1
		if i == 0
			return store
		endif
		
		return SubString(store, i)
	else
		return Substring(store, i, j - i)
	endif
endfunction

;-----\---------\
; SAFE \ GENERAL \
;--------------------------------------------------------

string function GetFormModName(form mod_form) global
	int form_id = mod_form.GetFormID()
	int index = RightShift(form_id, 24)

	; Light
	if index == 254
		return GetLightModName(RightShift(form_id, 12) - 0xFE000)
	endif
	; Normal
	return GetModName(index)
endfunction

; TODO(NeverLost): Implement
function CutStringArray(string[] stringArray, int cutIndex)
	;if stringArray.length < 2
	;	return stringArray
	;endIf

	;string[] newStringArray = CreateStringArray(stringArray.length - 1)
	;int oldAIndex
	;int newAIndex
		
	;while oldAIndex < stringArray.length && newAIndex < stringArray.length - 1
	;	if oldAIndex != cutIndex
	;		newStringArray[newAIndex] = stringArray[oldAIndex]
	;		newAIndex += 1
	;	endIf
	;		
	;	oldAIndex += 1
	;endWhile
	
	;return newStringArray
endFunction

;-----\-------------\
; SAFE \ GROUP STORE \
;--------------------------------------------------------
; DO NOT STORE:
; | or \ or ;

string function InsertGroupVal(string store, string group_id, string value) global
    if group_id == "" || value == ""
		return store
	endif
	
	int i = Find(store, "|" + group_id)
    
	; Group doesn't exist, create one
    if i == -1
        return store + "|" + group_id + "\\" + value + ";"
	endif
	
	int j = Find(store, "|", i + GetLength(group_id) + 2)
	
	; This is the last group
	if j == -1
		return store + value + ";"
	endif
	
	; This is not the last group
	return Substring(store, 0, j) + value + ";" + SubString(store, j)
endfunction

bool function HasGroup(string store, string group_id) global
	if Find(store, "|" + group_id) != -1
		return true
	endif
	return false
endfunction

bool function HasVal(string store, string value) global
	if Find(store, value + ";") != -1
		return true
	endif
	return false
endfunction

bool function HasGroupVal(string store, string group_id, string value) global
	int i = Find(store, "|" + group_id)
    
    if i == -1
        return false
    endif
	
	int j = Find(store, "|", i + GetLength(group_id) + 2)
	
	if Find(GetSpan(store, i, j), value + ";") != -1
		return true
	endif
	return false
endfunction

string[] function GetGroups(string store) global
	string[] groups = Split(store, "|")
	
	if !groups
		return None
	endif
	
	int i = groups.Length
	
	while i > 0
		i -= 1
		groups[i] = "|" + groups[i]
	endwhile

	return groups
endfunction

string function GetFirstGroupID(string store) global
    return SubString(store, 1, Find(store, "\\") - 1)
endfunction

string[]function GetGroupIDs(string store) global
	string[] groups = Split(store, "|")
	
	if !groups
		return None
	endif
	
	int i = groups.Length
	
	while i > 0
		i -= 1
		groups[i] = Substring(groups[i], 0, Find(groups[i], "\\"))
	endwhile
	
	return groups
endfunction

string[] function GetGroupVals(string store, string group_id = "") global
	if group_id == ""
		return None
	endif

    int i = Find(store, "|" + group_id)
    
    if i == -1
        return None
    endif
    
    int j = Find(store, "\\", i) + 1
    
	return Split(GetSpan(store, j, Find(store, "|", j)), ";")
endfunction

string function DelGroup(string store, string group_id) global
    if group_id == ""
		return store
	endif
	
	int i = Find(store, "|" + group_id)
    
    if i == -1
        return store
    endif
    
	int j = Find(store, "|", i + GetLength(group_id) + 2)
	
	return DelSpan(store, i, j)
endfunction

string function DelGroupVal(string store, string group_id, string value) global
	if group_id == "" || value == ""
		return store
	endif

	int i = Find(store, "|" + group_id)
    
    if i == -1
        return store
    endif

	int j = Find(store, value + ";")
	
	if j == -1
		return store
	endif
	
	int k = j + GetLength(value) + 1
	string last_c = GetNthChar(store, k)
	
	; Is first value in group
	if GetNthChar(store, j - 1) == "\\"
		; Is end group, and no more values left
		if last_c == ""
			return DelSpan(store, i, -1)
		; Is middle group, and no more values left
		elseif last_c == "|"
			return DelSpan(store, i, k)
		endif
	; Is end value in a group of several
	elseif last_c == ""
		return DelSpan(store, j, -1)
	endif
	
	; Value exists in the middle of a group
	return DelSpan(store, j, k)
endfunction
