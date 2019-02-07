# Location Helper

> 幫助我記得車子停哪裡的小工具

![](https://github.com/kevinguitar/LocationHelper/blob/master/screenshot.png)

### 使用情境
當你停好車時，按一下定位按鈕即會紀錄當下的位置，等要找車的時候再打開App即可<br>
其實這個簡單的小工具本來是用 Android 原生開發，但是身邊有些用 iOS 的朋友也想用<br>
於是就嘗試了 Google 新推出的 Flutter 框架來做開發！

### 過程中遇到的困難
1. Flutter 去年11月才推出 1.0 的正式版，所以這個專案的主要 plugin - Google Map 還是有些 bug 存在。解決方式是看到了網友在 issue 裡面提到了這些有 bug 的替代 function。
2. 最後要釋出給 iOS 使用者用的時候才發現就連上到 testflight 也需要開發者帳號QQ，於是只好徒手幫他們安裝進手機了，但好像又會有開發版 App 過期的狀況...
