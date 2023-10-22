export { default as PhoenixCustomEvent } from 'phoenix-custom-event-hook';
export const Card = {
  mounted() {
    VanillaTilt.init(this.el, {
      glare: true
    });
  }
}
export const UnopenedCardPack = {
  mounted() {
    VanillaTilt.init(this.el, {
      glare: true
    });
  }
}
export const UnopenedCardPacks = {
  mounted() {}
}
export const Face = {
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
    console.log("Checking if it's time to move the eye");
    if (this.isAwake) {
      if (Math.random() > 0.5) {
        console.log("Moving eye left");
        this.pushEvent("move-eye", { to: "left" });
      } else {
        console.log("Moving eye right");
        this.pushEvent("move-eye", { to: "right" });
      }
    }
    this.eyeMovement = setTimeout(this.moveEye.bind(this), 9999);
  },
  mounted() {
    console.log("Mounting");
    this.setup();
    this.recognition.start();
    setInterval(() => {
      this.recognition.stop();
      this.setup();
      this.recognition.start();
    }, 10000);
  }
}
