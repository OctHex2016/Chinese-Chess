兩部 M5 Max 128GB MacBook Pro，配 Xcode + Xcode Vibe，試下叫 AI 寫隻中國象棋。結果：幾得喎 😆 多謝某人借機！

今次用 mlx-community/Qwen3-Coder-480B-A35B-Instruct-4bit，大約 4 分鐘寫咗 1500 行 code。雖然中途有兩個 bug，搞到最初仲未行到棋，要我自己出手修正，但整體表現真係唔差，成品質素我會畀 中上。
當然，老實講，我今次都未算好用心去 prompt 佢，仲有唔少優化空間。

講返資源使用方面，跑 Coder 480B 用 Tensor + RDMA，full load 時每部機大約用咗 110GB RAM 左右，溫度大概 80°C 左右，表現算係幾靚。

再加少少人手執一執，隻 game 而家已經係 真係玩得又睇得。
所以我成日都覺得：學 programming basics 依然好重要。AI 可以幫你快好多，但最後識唔識 debug、識唔識接手，先係關鍵。

如果再加埋少少 hybrid workflow 去做 debug，應該仲可以慳返唔少 token。

之後試Kimi 2.... 

#VibeCoding #Xcode #SwiftUI #M5Max #MacBookPro #Qwen3Coder #MLX #中國象棋 #AppDevelopment #Debugging

https://www.facebook.com/share/r/18NiEScapg/?mibextid=wwXIfr
