# code for change social app

/* fb
"https://m.me/daiphamit"
"fb-messenger://user-thread/thuyduongle"
"zalo://"
""viber://add?number=84938388208""
*/

guard let url = URL(string: ) else {
return //be safe
}

if #available(iOS 10.0, *) {
UIApplication.shared.open(url, options: [:], completionHandler: nil)
} else {
UIApplication.shared.openURL(url)
}
