// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar";
import "../vendor/tilt";
import { Sortable, Plugins } from "../vendor/shopify/draggable";
import "../css/app.css"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: {
    _csrf_token: csrfToken,
  },
  hooks: {
    Card: {
      mounted() {
        VanillaTilt.init(this.el, {
          glare: true
        });
      }
    },
    UnopenedCardPack: {
      mounted() {
        VanillaTilt.init(this.el, {
          glare: true
        });
      }
    },
    UnopenedCardPacks: {
      mounted() {
      }
    },
    Face: {
      setup() {
        const SpeechRecognition = window.SpeechRecognition || webkitSpeechRecognition;
        this.recognition = new SpeechRecognition();
        this.recognition.lang = 'en-US';
        this.recognition.continuous = true;
        this.recognition.interimResults = true;
        this.recognition.onresult = ({ results }) => {
          console.log("I hear something");
          this.wakeUp();
          this.talk();
        };
      },
      wakeUp() {
        if (!this.isAwake) {
          console.log("I'm awake!");
          this.pushEvent("wake-up", {});
          this.moveEye();
          this.isAwake = true;
        }
      },
      talk() {
        if (!this.isTalking) {
          console.log("I'm talking!");
          this.pushEvent("talking", {});
          this.isTalking = true;
          this.quiet();
        }
      },
      quiet() {
        setTimeout((face) => {
          if (face.isTalking) {
            console.log("I'm quiet!");
            this.pushEvent("quiet", {});
            face.isTalking = false;
          }
        }, 100, this);
      },
      moveEye() {
        console.log("Checking if it's time to move the eye")
        if (this.isAwake) {
          if (Math.random() > 0.5) {
            console.log("Moving eye left")
            this.pushEvent("move-eye", {to: "left"});
          } else {
            console.log("Moving eye right")
            this.pushEvent("move-eye", {to: "right"});
          }
        }
        this.eyeMovement = setTimeout(this.moveEye.bind(this), 9999);
      },
      mounted() {
        console.log("Mounting")
        this.setup()
        this.recognition.start()
        setInterval(() => {
          this.recognition.stop();
          this.setup();
          this.recognition.start();
        }, 10000)
      }
    }
  }
});

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.delayedShow(200))
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
