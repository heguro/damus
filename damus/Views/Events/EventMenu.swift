//
//  EventMenu.swift
//  damus
//
//  Created by William Casarin on 2023-01-23.
//

import SwiftUI

struct EventMenuContext: View {
    let event: NostrEvent
    let keypair: Keypair
    let target_pubkey: String
    
    @State private var isBookmarked: Bool = false
    
    var body: some View {
    
        Button {
            UIPasteboard.general.string = event.get_content(keypair.privkey)
        } label: {
            Label(NSLocalizedString("Copy Text", comment: "Context menu option for copying the text from an note."), systemImage: "doc.on.doc")
        }

        Button {
            UIPasteboard.general.string = bech32_pubkey(target_pubkey)
        } label: {
            Label(NSLocalizedString("Copy User Pubkey", comment: "Context menu option for copying the ID of the user who created the note."), systemImage: "person")
        }

        Button {
            UIPasteboard.general.string = bech32_note_id(event.id) ?? event.id
        } label: {
            Label(NSLocalizedString("Copy Note ID", comment: "Context menu option for copying the ID of the note."), systemImage: "note.text")
        }

        Button {
            UIPasteboard.general.string = event_to_json(ev: event)
        } label: {
            Label(NSLocalizedString("Copy Note JSON", comment: "Context menu option for copying the JSON text from the note."), systemImage: "square.on.square")
        }
        
        Button {
            let event_json = event_to_json(ev: event)
            BookmarksManager(pubkey: keypair.pubkey).updateBookmark(event_json)
            isBookmarked = BookmarksManager(pubkey: keypair.pubkey).isBookmarked(event_json)
            notify(.update_bookmarks, event)
        } label: {
            let imageName = isBookmarked ? "bookmark.fill" : "bookmark"
            let unBookmarkString = NSLocalizedString("Un-Bookmark", comment: "Context menu option for un-bookmarking a note")
            let bookmarkString = NSLocalizedString("Bookmark", comment: "Context menu optoin for bookmarking a note")
            Label(isBookmarked ? unBookmarkString : bookmarkString, systemImage: imageName)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isBookmarked = BookmarksManager(pubkey: keypair.pubkey).isBookmarked(event_to_json(ev: event))
            }
        }

        Button {
            NotificationCenter.default.post(name: .broadcast_event, object: event)
        } label: {
            Label(NSLocalizedString("Broadcast", comment: "Context menu option for broadcasting the user's note to all of the user's connected relay servers."), systemImage: "globe")
        }
            
            if keypair.pubkey == target_pubkey {
                Button(role: .destructive) {
                    notify(.deleting, event)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }

        // Only allow reporting if logged in with private key and the currently viewed profile is not the logged in profile.
        if keypair.pubkey != target_pubkey && keypair.privkey != nil {
            Button(role: .destructive) {
                let target: ReportTarget = .note(ReportNoteTarget(pubkey: target_pubkey, note_id: event.id))
                notify(.report, target)
            } label: {
                Label(NSLocalizedString("Report", comment: "Context menu option for reporting content."), systemImage: "exclamationmark.bubble")
            }

            Button(role: .destructive) {
                notify(.block, target_pubkey)
            } label: {
                Label(NSLocalizedString("Block", comment: "Context menu option for blocking users."), systemImage: "exclamationmark.octagon")
            }
        }
    }
}

/*
struct EventMenu: UIViewRepresentable {
    
    typealias UIViewType = UIButton

    let saveAction = UIAction(title: "") { action in }
    let saveMenu = UIMenu(title: "", children: [
        UIAction(title: "First Menu Item", image: UIImage(systemName: "nameOfSFSymbol")) { action in
            //code action for menu item
        },
        UIAction(title: "First Menu Item", image: UIImage(systemName: "nameOfSFSymbol")) { action in
            //code action for menu item
        },
        UIAction(title: "First Menu Item", image: UIImage(systemName: "nameOfSFSymbol")) { action in
            //code action for menu item
        },
    ])

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.showsMenuAsPrimaryAction = true
        button.menu = saveMenu
        
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.setImage(UIImage(systemName: "plus"), for: .normal)
    }
}

struct EventMenu_Previews: PreviewProvider {
    static var previews: some View {
        EventMenu(event: test_event, privkey: nil, pubkey: test_event.pubkey)
    }
}

*/
