;----------------------------------------------------
; Library Management System - Search by Author
;----------------------------------------------------
.MODEL SMALL
.STACK 100h

.DATA
; ================== GENERAL MESSAGES ==================
msg_welcome  DB 10,13,'=== LIBRARY MANAGEMENT SYSTEM ===$'
msg_role_menu DB 10,13,10,13,'--- MAIN MENU ---$'
msg_role1    DB 10,13,'1. Admin Login$'
msg_role2    DB 10,13,'2. User Login$'
msg_role0    DB 10,13,'0. Exit Program$'
msg_select   DB 10,13,'Select option: $'
msg_continue DB 10,13,10,13,'Press any key to continue...$'
msg_exit     DB 10,13,10,13,'Thank you for using the system!$'

; ================== ADMIN DATA ==================
msg_admin_menu1 DB 10,13,10,13,'--- ADMIN MENU ---$'
msg_admin_menu2 DB 10,13,'1) Add Book$'
msg_admin_menu3 DB 10,13,'2) List Books$'
msg_admin_menu4 DB 10,13,'3) Search for a Book$'
msg_admin_menu5 DB 10,13,'4) Update Book$'
msg_admin_menu6 DB 10,13,'5) Delete Book$'
msg_admin_menu0 DB 10,13,'0) Logout$'
msg_admin_login DB 10,13,'Enter Admin PIN (4 digits): $'
msg_badpin      DB 10,13,'Invalid PIN. Try again.$'
admin_pin    DB '1','2','3','4'
temp_pin     DB 4 DUP(?)

; ================== USER DATA ==================
msg_user_menu1 DB 10,13,10,13,'--- USER MENU ---$'
msg_user_menu2 DB 10,13,'1. List All Books$'
msg_user_menu3 DB 10,13,'2. Search for a Book$'
msg_user_menu4 DB 10,13,'3. Borrow Book$'
msg_user_menu5 DB 10,13,'4. Return Book$'
msg_user_menu6 DB 10,13,'5. View My Borrowed Books$'
msg_user_menu0 DB 10,13,'0. Logout$'
msg_user_login_id DB 10,13,'Enter User ID: $'
msg_user_login_pw DB 10,13,'Enter PIN (4 digits): $'
msg_bad_login   DB 10,13,'Invalid User ID or PIN.$'
msg_lock     DB 10,13,'Too many failed attempts.$'

user_count      DB 4
user_ids        DB 'a','b','c','d'
user_passwords  DB '1111','2222','3333','4444'
current_user    DB ?

; ================== BOOK DATABASE ==================
book_capacity DB 10
book_count    DB 2
book_ids      DB '0','1', 8 DUP(0)
book_titles   DB 'Cosmos              ','Dune                ', 160 DUP(' ')
book_authors  DB 'Carl Sagan          ','Frank Herbert       ', 160 DUP(' ')
book_status   DB 'A','A', 8 DUP('A')
borrowed_by   DB 10 DUP(0)   

; --- Add/Update/Delete/Search Messages ---
msg_addbook  DB 10,13,'--- Add New Book ---$'
msg_entertit DB 10,13,'Enter Book Title (max 20 chars): $'
msg_enterauth DB 10,13,'Enter Book Author (max 20 chars): $'
msg_full     DB 10,13,'Database is full! Cannot add more.$'
msg_added    DB 10,13,'Book added successfully!$'
msg_search_menu DB 10,13,10,13,'--- Search Menu ---$'
msg_search_opt1 DB 10,13,'1. Search by Title$'
msg_search_opt2 DB 10,13,'2. Search by Author$'
msg_search_by_title DB 10,13,'Enter title to search for: $'
msg_search_by_author DB 10,13,'Enter author to search for: $'
search_buffer       DB 21 DUP(?)
search_len          DB 0
msg_bookfound       DB 10,13,'Book found! Details:$'
msg_notfound        DB 10,13,'Book was not found.$'
msg_updateprompt   DB 10,13,'From the list above, enter ID of book to update: $'
msg_updating       DB 10,13,'Updating the following book:$'
msg_newtitleprompt DB 10,13,'Enter the new title: $'
msg_updated        DB 10,13,'Book updated successfully.$'
msg_deleteprompt DB 10,13,'From the list above, enter ID of book to delete: $'
msg_deleted      DB 10,13,'Book deleted successfully.$'
msg_listheader DB 10,13,10,13,'--- BOOK LIST ---',10,13,'ID - Status - Title               - Author',10,13,'--------------------------------------------------------$'
msg_nobooks    DB 10,13,'Database is empty.$'
msg_borrowprompt DB 10,13,'From the list above, enter ID of book to borrow: $'
msg_borrowed   DB 10,13,'Book borrowed successfully!$'
msg_notavail   DB 10,13,'Sorry, that book is not available.$'
msg_returnprompt DB 10,13,'From the list above, enter ID of book to return: $'
msg_returned     DB 10,13,'Book returned successfully!$'
msg_notborrowed  DB 10,13,'Error: You have not borrowed this book.$'
msg_mybooks_header DB 10,13,'--- My Borrowed Books ---$'
msg_mybooks_none   DB 10,13,'You have no books borrowed.$'

; Overdue tracking and messages
overdue_flags DB 10 DUP(0) ; 0 = not overdue, 1 = overdue

msg_overdue_list DB 10,13,'--- OVERDUE BOOKS ---$'
msg_set_overdue_prompt DB 10,13,'Enter Book ID to mark overdue: $'
msg_overdue_set DB 10,13,'Overdue marked!$'
msg_overdue_warning DB 10,13,'*** You have overdue book(s)! Please return them. ***',10,13,'$'
msg_no_overdues DB 10,13,'No overdue books found.$'
msg_admin_menu8 DB 10,13,'6) List Overdue Books$'


.CODE
MAIN PROC
    mov ax,@DATA
    mov ds,ax

RoleSelectionLoop:
    lea dx, msg_welcome
    mov ah,9
    int 21h
    lea dx, msg_role_menu
    mov ah,9
    int 21h
    lea dx, msg_role1
    mov ah,9
    int 21h
    lea dx, msg_role2
    mov ah,9
    int 21h
    lea dx, msg_role0
    mov ah,9
    int 21h
    lea dx, msg_select
    mov ah,9
    int 21h
    
    call ReadChar
    mov bh, al
    call PrintNewline
    mov al, bh

    cmp al, '1'
    je GoAdmin
    cmp al, '2'
    je GoUser
    cmp al, '0'
    je ExitProgram
    
    jmp RoleSelectionLoop

GoAdmin:
    call AdminModule
    jmp RoleSelectionLoop
GoUser:
    call UserModule
    jmp RoleSelectionLoop
ExitProgram:
    lea dx, msg_exit
    mov ah, 9
    int 21h
    mov ax,4C00h
    int 21h
MAIN ENDP

; =================================================================
; ========================= ADMIN MODULE ==========================
; =================================================================
AdminModule PROC
    call AdminLogin
    cmp al, 0 
    je AdminExit
AdminMenuLoop:
    lea dx,msg_admin_menu1
    mov ah,9
    int 21h
    lea dx,msg_admin_menu2
    mov ah,9
    int 21h
    lea dx,msg_admin_menu3
    mov ah,9
    int 21h
    lea dx,msg_admin_menu4
    mov ah,9
    int 21h
    lea dx,msg_admin_menu5
    mov ah,9
    int 21h
    lea dx,msg_admin_menu6
    mov ah,9
    int 21h
    ; Add menu option
    lea dx,msg_admin_menu8
    mov ah,9
    int 21h

    lea dx,msg_admin_menu0
    mov ah,9
    int 21h
    lea dx,msg_select
    mov ah,9
    int 21h
    call ReadChar
    mov bh, al
    call PrintNewline
    mov al, bh
    cmp al,'1'
    je DoAdd
    cmp al,'2'
    je DoList
    cmp al,'3'
    je DoSearch
    cmp al,'4'
    je DoUpdate
    cmp al,'5'
    je DoDelete
    cmp al,'6'
    je DoListOverdue
    cmp al,'0'
    je AdminExit
    jmp AdminMenuLoop
DoAdd:
    call AddBook
    jmp AdminMenuLoop
DoList:
    call ListBooks
    jmp AdminMenuLoop
DoSearch:
    call SearchBook
    jmp AdminMenuLoop
DoUpdate:
    call UpdateBook
    jmp AdminMenuLoop
DoDelete:
    call DeleteBook
    jmp AdminMenuLoop
DoListOverdue:
    call ListOverdueBooks
    call MarkBookOverdue ; Prompt to mark overdue after listing
    jmp AdminMenuLoop
AdminExit:
    ret
AdminModule ENDP

AdminLogin PROC
    mov bl,3                    ; bl = number of allowed attempts

LoginTry:
    lea dx,msg_admin_login
    mov ah,9
    int 21h

    ; Read 4-digit PIN, mask each digit
    call ReadChar
    mov temp_pin[0], al
    mov al,'*'
    call PrintCharAL

    call ReadChar
    mov temp_pin[1], al
    mov al,'*'
    call PrintCharAL

    call ReadChar
    mov temp_pin[2], al
    mov al,'*'
    call PrintCharAL

    call ReadChar
    mov temp_pin[3], al
    mov al,'*'
    call PrintCharAL

    call PrintNewline

    mov si, 0                 
    mov cx, 4                 

AdminPinCheck:
    mov al, temp_pin[si]      
    mov dl, admin_pin[si]     
    cmp al, dl               
    jne WrongAdminPin         
    inc si
    loop AdminPinCheck       

    mov al, 1                
    ret

WrongAdminPin:
    lea dx,msg_badpin
    mov ah,9
    int 21h

    dec bl                    
    cmp bl,0                   
    je Lockout                
    jmp LoginTry               

Lockout:
    lea dx,msg_lock
    mov ah,9
    int 21h
    call Pause
    mov al, 0                 
    ret

AdminLogin ENDP

; =================================================================
; ========================== USER MODULE ==========================
; =================================================================
UserModule PROC
    call UserLogin
    cmp al, 0 
    je UserExit
UserMenuLoop:
    call CheckUserOverdue
    lea dx, msg_user_menu1
    mov ah, 9
    int 21h
    lea dx, msg_user_menu2
    mov ah, 9
    int 21h
    lea dx, msg_user_menu3
    mov ah, 9
    int 21h
    lea dx, msg_user_menu4
    mov ah, 9
    int 21h
    lea dx, msg_user_menu5
    mov ah, 9
    int 21h               
    lea dx, msg_user_menu6
    mov ah, 9
    int 21h
    lea dx, msg_user_menu0
    mov ah, 9
    int 21h
    lea dx, msg_select
    mov ah,9
    int 21h
    call ReadChar
    mov bh, al
    call PrintNewline
    mov al, bh
    cmp al, '1'
    je DoList_User
    cmp al, '2'
    je DoSearch_User
    cmp al, '3'
    je DoBorrow
    cmp al, '4'
    je DoReturn
    cmp al, '5'
    je DoViewMyBooks
    cmp al, '0'
    je UserExit
    jmp UserMenuLoop
DoList_User:
    call ListBooks
    jmp UserMenuLoop
DoSearch_User:
    call SearchBook
    jmp UserMenuLoop
DoBorrow:
    call BorrowBook
    jmp UserMenuLoop
DoReturn:
    call ReturnBook
    jmp UserMenuLoop
DoViewMyBooks:
    call ViewMyBooks
    jmp UserMenuLoop

UserExit:
    ret
UserModule ENDP

UserLogin PROC
    mov bl, 3 
UserLoginTry:
    lea dx, msg_user_login_id
    mov ah, 9
    int 21h
    call ReadChar
    mov bh, al 
    call PrintNewline
    lea dx, msg_user_login_pw
    mov ah, 9
    int 21h
    call ReadChar
    mov temp_pin[0], al
    mov al,'*'
    call PrintCharAL
    call ReadChar
    mov temp_pin[1], al
    mov al,'*'
    call PrintCharAL
    call ReadChar
    mov temp_pin[2], al
    mov al,'*'
    call PrintCharAL
    call ReadChar
    mov temp_pin[3], al
    mov al,'*'
    call PrintCharAL
    call PrintNewline
    mov si, 0
    mov cl, [user_count]
    mov ch, 0
UserFindLoop:
    mov al, user_ids[si]
    cmp al, bh
    je UserFound_Login
    inc si
    loop UserFindLoop
    jmp BadLogin 
UserFound_Login:
    mov di, si
    mov ax, di
    mov ah, 0
    mov dl, 4
    mul dl
    mov di, ax 
    mov si, 0
    mov cx, 4
UserPinCheck:
    mov al, temp_pin[si]
    mov dl, user_passwords[di]
    cmp al, dl
    je UserPinMatch
    jmp BadLogin
UserPinMatch:
    inc si
    inc di
    loop UserPinCheck
    mov al, bh
    mov [current_user], al
    mov al, 1 
    ret
BadLogin:
    lea dx, msg_bad_login
    mov ah, 9
    int 21h
    dec bl
    cmp bl, 0
    je LockoutUser
    jmp UserLoginTry
LockoutUser:
    lea dx, msg_lock
    mov ah,9
    int 21h
    call Pause
    mov al, 0 
    ret
UserLogin ENDP

BorrowBook PROC
    mov al, [book_count]
    cmp al, 0
    je NoBooksInDB
    call ListBooks 
    lea dx, msg_borrowprompt
    mov ah, 9
    int 21h
    call ReadChar
    mov bh, al 
    call PrintNewline
    mov cl, [book_count]
    mov ch, 0       
    mov si, 0 
Borrow_SearchLoop:
    mov al, book_ids[si] 
    cmp al, bh           
    je Borrow_BookFound 
    inc si
    loop Borrow_SearchLoop
    lea dx, msg_notfound
    mov ah, 9
    int 21h
    call Pause
    ret
Borrow_BookFound:
    mov al, book_status[si]
    cmp al, 'A'
    je BorrowAvailable
    jmp NotAvailable
BorrowAvailable:
    mov book_status[si], 'B'
    mov al, [current_user]
    mov borrowed_by[si], al
    lea dx, msg_borrowed
    mov ah, 9
    int 21h
    call Pause
    ret
NotAvailable:
    lea dx, msg_notavail
    mov ah, 9
    int 21h
    call Pause
    ret
BorrowBook ENDP

ReturnBook PROC
    mov al, [book_count]
    cmp al, 0
    je NoBooksInDB
    call ViewMyBooks 
    lea dx, msg_returnprompt
    mov ah, 9
    int 21h
    call ReadChar
    mov bh, al 
    call PrintNewline
    mov cl, [book_count]
    mov ch, 0
    mov si, 0 
Return_SearchLoop:
    mov al, book_ids[si] 
    cmp al, bh           
    je Return_BookFound 
    inc si
    loop Return_SearchLoop
    lea dx, msg_notfound
    mov ah, 9
    int 21h
    call Pause
    ret
Return_BookFound:
    mov al, borrowed_by[si]
    cmp al, [current_user]
    je ReturnYourBook
    jmp NotYourBook
ReturnYourBook:
    mov book_status[si], 'A'
    mov borrowed_by[si], 0
    lea dx, msg_returned
    mov ah, 9
    int 21h
    call Pause
    ret
NotYourBook:
    lea dx, msg_notborrowed
    mov ah, 9
    int 21h
    call Pause
    ret
ReturnBook ENDP

ViewMyBooks PROC
    lea dx, msg_mybooks_header
    mov ah, 9
    int 21h
    call PrintNewline
    mov cl, [book_count]
    mov ch, 0          
    mov si, 0
    mov bl, 0 
ViewMyBooks_Loop:
    cmp si, cx
    jge ViewMyBooks_Done   
    mov al, borrowed_by[si]
    cmp al, [current_user]
    je PrintMyBook
    jmp NextMyBook
PrintMyBook:
    mov bl, 1 
    push cx
    push si
    ; Print book ID
    mov al, book_ids[si]
    call PrintCharAL
    mov dl, ' '
    mov ah, 2
    int 21h
    ; Print book status
    mov al, book_status[si]
    call PrintCharAL
    mov dl, ' '
    mov ah, 2
    int 21h
    ; Print separator
    mov dl, '-'
    mov ah, 2
    int 21h
    mov dl, ' '
    mov ah, 2
    int 21h
    ; Print book title (20 chars)
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_titles
    add bx, ax
    mov cx, 20
ViewMyBooks_PrintTitle:
    mov al, [bx]
    call PrintCharAL
    inc bx
    loop ViewMyBooks_PrintTitle
    ; Print author separator (same style as ListBooks)
    mov dl, ' '
    mov ah, 2
    int 21h
    mov dl, '-'
    mov ah, 2
    int 21h
    mov dl, ' '
    mov ah, 2
    int 21h
    ; Print book author (20 chars)
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_authors
    add bx, ax
    mov cx, 20
ViewMyBooks_PrintAuthor:
    mov al, [bx]
    call PrintCharAL
    inc bx
    loop ViewMyBooks_PrintAuthor
    call PrintNewline
    pop si
    pop cx
NextMyBook:
    inc si
    jmp ViewMyBooks_Loop
ViewMyBooks_Done:
    cmp bl, 0
    je MyBooksNone
    jmp MyBooksEnd
MyBooksNone:
    lea dx, msg_mybooks_none
    mov ah, 9
    int 21h
MyBooksEnd:
    call Pause
    ret
ViewMyBooks ENDP


; =================================================================
; =================== SHARED & HELPER PROCEDURES ==================
; =================================================================

ReadChar PROC
    mov ah, 1
    int 21h
    ret
ReadChar ENDP

ReadString PROC
    mov cl, 0
ReadStringLoop:
    call ReadChar
    cmp al, 13
    je ReadStringDone
    mov [di], al
    inc di
    inc cl
    cmp cl, 20
    je ReadStringDone
    jmp ReadStringLoop
ReadStringDone:
    mov [search_len], cl
    call PrintNewline
    ret
ReadString ENDP

PrintCharAL PROC
    mov dl,al
    mov ah,2
    int 21h
    ret
PrintCharAL ENDP

PrintNewline PROC
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h
    ret
PrintNewline ENDP

Pause PROC
    lea dx, msg_continue
    mov ah, 9
    int 21h
    mov ah, 1
    int 21h
    ret
Pause ENDP

ListBooks PROC
    mov al, [book_count]
    cmp al, 0
    je NoBooksInDB
    lea dx, msg_listheader
    mov ah, 9
    int 21h
    call PrintNewline
    mov cl, [book_count]
    mov ch, 0        
    mov si, 0
ListBooksLoop:
    push cx
    mov al, book_ids[si]
    call PrintCharAL
    mov dl, ' '
    mov ah, 2
    int 21h
    mov al, book_status[si]
    call PrintCharAL
    mov dl, ' '
    mov ah, 2
    int 21h
    mov dl, '-'
    mov ah, 2
    int 21h
    mov dl, ' '
    mov ah, 2
    int 21h
    mov bx, OFFSET book_titles
    mov cx, si
    cmp cx, 0
    je  OffsetReady_L
OffsetCalcLoop_L:
    add bx, 20
    loop OffsetCalcLoop_L
OffsetReady_L:
    mov cx, 20
PrintTitleLoop_L:
    mov al, [bx]
    call PrintCharAL
    inc bx
    loop PrintTitleLoop_L
    mov dl, ' '
    mov ah, 2
    int 21h
    mov dl, '-'
    mov ah, 2
    int 21h
    mov dl, ' '
    mov ah, 2
    int 21h
    mov bx, OFFSET book_authors
    mov cx, si
    cmp cx, 0
    je OffsetReady_A
OffsetCalcLoop_A:
    add bx, 20
    loop OffsetCalcLoop_A
OffsetReady_A:
    mov cx, 20
PrintAuthorLoop_A:
    mov al, [bx]
    call PrintCharAL
    inc bx
    loop PrintAuthorLoop_A
    call PrintNewline
    pop cx
    inc si
    loop ListBooksLoop
    call Pause
    ret
NoBooksInDB:
    lea dx, msg_nobooks
    mov ah, 9
    int 21h
    call Pause
    ret
ListBooks ENDP

SearchBook PROC
    mov al, [book_count]
    cmp al, 0
    je NoBooksInDB
    lea dx, msg_search_menu
    mov ah, 9
    int 21h
    lea dx, msg_search_opt1
    mov ah, 9
    int 21h
    lea dx, msg_search_opt2
    mov ah, 9
    int 21h
    lea dx, msg_select
    mov ah, 9
    int 21h
    call ReadChar
    mov bh, al
    call PrintNewline
    mov al, bh
    cmp al, '1'
    je SearchByTitle
    cmp al, '2'
    je SearchByAuthor
    ret
SearchByTitle:
    call SearchByTitleProc
    ret
SearchByAuthor:
    call SearchByAuthorProc
    ret
SearchBook ENDP

SearchByTitleProc PROC
    lea dx, msg_search_by_title
    mov ah, 9
    int 21h
    lea di, search_buffer
    call ReadString
    mov cl, [book_count]
    mov ch, 0        
    mov si, 0 
SearchOuterLoop:
    push cx 
    push si 
    mov cl, [search_len]
    cmp cl, 0
    je SearchNextBook
    mov ch, 0     
    lea di, search_buffer
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_titles
    add bx, ax
SearchInnerLoop:
    mov al, [di]
    cmp al, [bx]
    jne SearchNextBook
    inc di
    inc bx
    loop SearchInnerLoop
    pop si 
    pop cx 
    jmp BookFound_Search
SearchNextBook:
    pop si
    pop cx
    inc si
    loop SearchOuterLoop
    lea dx, msg_notfound
    mov ah, 9
    int 21h
    call Pause
    ret
BookFound_Search:
    lea dx, msg_bookfound
    mov ah, 9
    int 21h
    call PrintNewline

    ; Print book ID
    mov al, book_ids[si]
    call PrintCharAL
    mov dl, ' '
    mov ah, 2
    int 21h

    ; Print book status
    mov al, book_status[si]
    call PrintCharAL
    mov dl, ' '
    mov ah, 2
    int 21h

    ; Print separator
    mov dl, '-'
    mov ah, 2
    int 21h
    mov dl, ' '
    mov ah, 2
    int 21h

    ; Print book title (20 chars)
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_titles
    add bx, ax
    mov cx, 20
TitleLoop_Search:
    mov al, [bx]
    call PrintCharAL
    inc bx
    loop TitleLoop_Search

    ; Print author separator (same style as ListBooks)
    mov dl, ' '
    mov ah, 2
    int 21h
    mov dl, '-'
    mov ah, 2
    int 21h
    mov dl, ' '
    mov ah, 2
    int 21h

    ; Print book author (20 chars)
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_authors
    add bx, ax
    mov cx, 20
AuthorLoop_Search:
    mov al, [bx]
    call PrintCharAL
    inc bx
    loop AuthorLoop_Search

    call PrintNewline
    call Pause
    ret
SearchByTitleProc ENDP

SearchByAuthorProc PROC
    lea dx, msg_search_by_author
    mov ah, 9
    int 21h
    lea di, search_buffer
    call ReadString
    mov cl, [book_count]
    mov ch, 0      
    mov si, 0 
SearchAuthorOuterLoop:
    push cx 
    push si 
    mov cl, [search_len]
    cmp cl, 0
    je SearchAuthorNextBook
    mov ch, 0     
    lea di, search_buffer
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_authors
    add bx, ax
SearchAuthorInnerLoop:
    mov al, [di]
    cmp al, [bx]
    jne SearchAuthorNextBook
    inc di
    inc bx
    loop SearchAuthorInnerLoop
    pop si 
    pop cx 
    jmp BookFound_Search
SearchAuthorNextBook:
    pop si
    pop cx
    inc si
    loop SearchAuthorOuterLoop
    lea dx, msg_notfound
    mov ah, 9
    int 21h
    call Pause
    ret
SearchByAuthorProc ENDP

UpdateBook PROC
    mov al, [book_count]
    cmp al, 0
    je NoBooksInDB
    call ListBooks 
    lea dx, msg_updateprompt
    mov ah, 9
    int 21h
    call ReadChar
    mov bh, al 
    call PrintNewline
    mov cl, [book_count]
    mov ch, 0      
    mov si, 0 
Update_SearchLoop:
    mov al, book_ids[si] 
    cmp al, bh           
    je Update_BookFound 
    inc si
    loop Update_SearchLoop
    lea dx, msg_notfound
    mov ah, 9
    int 21h
    call Pause
    ret
Update_BookFound:
    lea dx, msg_updating
    mov ah, 9
    int 21h
    call PrintNewline
    mov al, book_ids[si]
    call PrintCharAL
    mov dl, ' '
    mov ah, 2
    int 21h
    mov dl, '-'
    mov ah, 2
    int 21h
    mov dl, ' '
    mov ah, 2
    int 21h
    push si
    mov bx, OFFSET book_titles
    mov cx, si
    cmp cx, 0
    je  Update_OffsetReady
Update_OffsetCalcLoop:
    add bx, 20
    loop Update_OffsetCalcLoop
Update_OffsetReady:
    mov cx, 20
Update_PrintTitleLoop:
    mov al, [bx]
    call PrintCharAL
    inc bx
    loop Update_PrintTitleLoop
    call PrintNewline
    pop si
    lea dx, msg_newtitleprompt
    mov ah,9
    int 21h
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_titles
    add bx, ax
    mov cx, 20
Update_TitleInputLoop:
    call ReadChar
    cmp al,13
    je Update_TitlePad
    mov [bx], al
    inc bx
    loop Update_TitleInputLoop
    call PrintNewline
    jmp Update_TitleDone
Update_TitlePad:
    call PrintNewline
Update_PadLoop:
    cmp cx, 0
    je Update_TitleDone
    mov byte ptr [bx], ' '
    inc bx
    dec cx
    jmp Update_PadLoop
Update_TitleDone:
    lea dx, msg_updated
    mov ah,9
    int 21h
    call Pause
    ret
UpdateBook ENDP

DeleteBook PROC
    mov al, [book_count]
    cmp al, 0
    je NoBooksInDB
    call ListBooks 
    lea dx, msg_deleteprompt
    mov ah, 9
    int 21h
    call ReadChar
    mov bh, al 
    call PrintNewline
    mov cl, [book_count]
    mov ch, 0      
    mov si, 0 
Delete_SearchLoop:
    mov al, book_ids[si] 
    cmp al, bh           
    je Delete_BookFound 
    inc si
    loop Delete_SearchLoop
    lea dx, msg_notfound
    mov ah, 9
    int 21h
    call Pause
    ret
Delete_BookFound:
    mov cl, [book_count]
    mov ch, 0      
    dec cx 
    cmp si, cx
    jge JustDecrementCount 
ShiftLoop:
    mov di, si
    inc di     
    ; Shift id, status, borrowed_by 
    mov al, book_ids[di]
    mov book_ids[si], al
    mov al, book_status[di]
    mov book_status[si], al
    mov al, borrowed_by[di]
    mov borrowed_by[si], al

    ; Shift title 
    push si
    push di
    push cx
    mov ax, di
    mov bl, 20
    mul bl
    mov di, OFFSET book_titles
    add di, ax 
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_titles
    add bx, ax 
    mov cx, 20
CopyTitleBytes:
    mov al, [di]
    mov [bx], al
    inc di
    inc bx
    loop CopyTitleBytes

    ; Shift author 
    pop cx
    pop di
    pop si
    push si
    push di
    push cx
    mov ax, di
    mov bl, 20
    mul bl
    mov di, OFFSET book_authors
    add di, ax
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_authors
    add bx, ax
    mov cx, 20
CopyAuthorBytes:
    mov al, [di]
    mov [bx], al
    inc di
    inc bx
    loop CopyAuthorBytes
    pop cx
    pop di
    pop si

    inc si
    cmp si, cx
    jl ShiftLoop
JustDecrementCount:
    dec byte ptr [book_count]
    lea dx, msg_deleted
    mov ah, 9
    int 21h
    call Pause
    ret
DeleteBook ENDP

AddBook PROC
    mov al, [book_count]
    cmp al, [book_capacity]
    je DbFull
    lea dx, msg_addbook
    mov ah,9
    int 21h
    mov bh, '0' 
FindID_OuterLoop:
    mov cl, [book_count]
    cmp cl, 0
    je Found_Available_ID
    mov ch, 0       
    mov si, 0
FindID_InnerLoop:
    mov al, book_ids[si]
    cmp al, bh
    je ID_Is_Taken
    inc si
    loop FindID_InnerLoop
    jmp Found_Available_ID
ID_Is_Taken:
    inc bh
    jmp FindID_OuterLoop
Found_Available_ID:
    mov al, bh 
    mov si, 0
    mov cl, [book_count]
    mov ch, 0
    mov si, cx 
    mov book_ids[si], al
    mov book_status[si], 'A'
    mov borrowed_by[si], 0
    lea dx, msg_entertit
    mov ah,9
    int 21h
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_titles
    add bx, ax
    mov cx, 20
TitleInputLoop:
    call ReadChar
    cmp al,13
    je TitlePad
    mov [bx], al
    inc bx
    loop TitleInputLoop
    call PrintNewline
    jmp TitleDone
TitlePad:
    call PrintNewline
PadLoop:
    cmp cx, 0
    je TitleDone
    mov byte ptr [bx], ' '
    inc bx
    dec cx
    jmp PadLoop
TitleDone:
    lea dx, msg_enterauth
    mov ah, 9
    int 21h
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_authors
    add bx, ax
    mov cx, 20
AuthorInputLoop:
    call ReadChar
    cmp al, 13
    je AuthorPad
    mov [bx], al
    inc bx
    loop AuthorInputLoop
    call PrintNewline
    jmp AuthorDone
AuthorPad:
    call PrintNewline
AuthorPadLoop:
    cmp cx, 0
    je AuthorDone
    mov [bx], ' '
    inc bx
    dec cx
    jmp AuthorPadLoop
AuthorDone:
    inc byte ptr [book_count]
    lea dx, msg_added
    mov ah,9
    int 21h
    call Pause
    ret
DbFull:
    lea dx, msg_full
    mov ah,9
    int 21h
    call Pause
    ret
AddBook ENDP



;ListOverdueBooks proc

ListOverdueBooks PROC
    lea dx, msg_overdue_list
    mov ah, 9
    int 21h
    call PrintNewline

    mov cl, [book_count]
    mov ch, 0
    mov si, 0
    mov bl, 0    ; bl = overdue count
ListOverdueLoop:
    cmp si, cx
    jge DoneListOverdue
    mov al, overdue_flags[si]
    cmp al, 1
    jne NextBookOverdue
    inc bl   ; count overdue found

    ; Print book ID
    mov al, book_ids[si]
    call PrintCharAL
    mov dl, ' '
    mov ah, 2
    int 21h

    ; Print borrower ID
    mov al, borrowed_by[si]
    call PrintCharAL
    mov dl, ' '
    mov ah, 2
    int 21h

    ; Print separator and book title
    mov dl, '-'
    mov ah, 2
    int 21h
    mov dl, ' '
    mov ah, 2
    int 21h
    mov ax, si
    mov bl, 20
    mul bl
    mov bx, OFFSET book_titles
    add bx, ax
    mov cx, 20
PrintOverdueTitle:
    mov al, [bx]
    call PrintCharAL
    inc bx
    loop PrintOverdueTitle
    call PrintNewline
NextBookOverdue:
    inc si
    jmp ListOverdueLoop
DoneListOverdue:
    cmp bl, 0
    jne OverdueFound
    lea dx, msg_no_overdues
    mov ah, 9
    int 21h
OverdueFound:
    call Pause
    ret
ListOverdueBooks ENDP

; Mark Overdue book proc
MarkBookOverdue PROC
    lea dx, msg_set_overdue_prompt
    mov ah, 9
    int 21h
    call ReadChar
    mov bh, al
    mov cl, [book_count]
    mov ch, 0
    mov si, 0
FindBookIDOverdue:
    mov al, book_ids[si]
    cmp al, bh
    je MarkThisBookOverdue
    inc si
    loop FindBookIDOverdue
    ret
MarkThisBookOverdue:
    mov overdue_flags[si], 1
    lea dx, msg_overdue_set
    mov ah, 9
    int 21h
    call Pause
    ret
MarkBookOverdue ENDP

;check_overdu proc
CheckUserOverdue PROC
    mov cl, [book_count]
    mov ch, 0
    mov si, 0
CheckUserOverdueLoop:
    cmp si, cx
    jge DoneCheckUserOverdue
    mov al, borrowed_by[si]
    cmp al, [current_user]
    jne NextCheckUserOverdue
    mov al, overdue_flags[si]
    cmp al, 1
    jne NextCheckUserOverdue
    mov dl, 7     ; ASCII BEL (beep)
    mov ah, 2
    int 21h
    lea dx, msg_overdue_warning
    mov ah, 9
    int 21h
    jmp DoneCheckUserOverdue
NextCheckUserOverdue:
    inc si
    jmp CheckUserOverdueLoop
DoneCheckUserOverdue:
    ret
CheckUserOverdue ENDP

END MAIN