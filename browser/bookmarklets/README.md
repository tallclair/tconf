# Bookmarklets

A *bookmarklet* is a javascript bookmark that performs a simple function. It is basically a light-weight browser extension.

### Installation

Just create a new bookmark (on chrome: right-click bookmarks or bookmark bar -> "Add page..."), and
paste the bookmarklet script as the URL.

## Godoc navigation from github

Use this bookmarklet to easily navigate from a golang package on github to its
[godoc](https://godoc.org/) page.

<!-- BOOKMARKLET=godoc.js -->
```javascript
javascript:(function(){
window.location='https://godoc.org/?q='+encodeURIComponent(window.location);
})()
```
<!-- /BOOKMARKLET -->
