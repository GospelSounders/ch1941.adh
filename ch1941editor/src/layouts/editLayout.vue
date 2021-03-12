<template>
  <!-- <q-layout view="lHh Lpr lFf"> -->
  <q-layout view="hHh Lpr lFf">
    <q-header elevated>
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          icon="menu"
          aria-label="Menu"
          @click="leftDrawerOpen = !leftDrawerOpen"
        />

        <q-toolbar-title> CH1941 Editor </q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-drawer
      ref="drawer"
      v-model="leftDrawerOpen"
      @mouseout="mouseOutofDrawer"
      overlay
      bordered
      :breakpoint="500"
      persist
      content-class="bg-primary text-white"
    >
      <q-list>
        <q-expansion-item
          group="somegroup"
          icon="folder_open"
          label="Open"
          clickable
        >
          <q-card class="bg-primary">
            <q-card-section>
              <q-list>
                <q-item tag="a" @click="openOriginal = true">
                  <q-item-section avatar>
                    <q-icon name="folder_open" />
                  </q-item-section>
                  <q-item-section>
                    <q-item-label> Original Files</q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>
            </q-card-section>
          </q-card>
        </q-expansion-item>

        <q-separator />
        <q-item v-if="loggedIn" clickable @click="logout">
          <q-item-section avatar>
            <q-icon name="logout" />
          </q-item-section>
          <q-item-section>
            <q-item-label>Log out</q-item-label>
          </q-item-section>
        </q-item>
        <q-item v-if="!loggedIn" clickable @click="loginDialog = true">
          <q-item-section avatar>
            <q-icon name="login" />
          </q-item-section>
          <q-item-section>
            <q-item-label>Log in</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </q-drawer>

    <q-dialog
      v-model="openOriginal"
      transition-show="rotate"
      transition-hide="rotate"
    >
      <q-card>
        <q-card-section class="q-pt-none text-center text-h6">
          Open File
        </q-card-section>
        <q-form
          @submit="onSubmitOpenOriginal"
          @reset="onResetgtKey"
          class="q-gutter-md text-white"
        >
          <q-select
            clearable
            use-input
            @filter="filterFn"
            filled
            v-model="originalFile"
            :options="originals"
            label="File"
            lazy-rules
            :rules="[(val) => (val && val.length > 0) || 'Please select file']"
          />
          <q-card-actions align="right">
            <!-- <q-btn flat label="Decline" color="primary" v-close-popup /> -->
            <!-- <q-btn flat label="Accept" color="primary" v-close-popup /> -->
            <q-btn flat label="Cancel" color="primary" v-close-popup />
            <q-btn flat label="Ok" color="primary" type="submit" />
          </q-card-actions>
        </q-form>
      </q-card>
    </q-dialog>
    <q-dialog
      v-model="loginDialog"
      transition-show="rotate"
      transition-hide="rotate"
    >
      <q-card>
        <q-card-section class="q-pt-none text-center text-h6">
          Enter Key
        </q-card-section>
        <q-card-actions align="right">
          <q-form
            @submit="onSubmitgtKey"
            @reset="onResetgtKey"
            class="q-gutter-md text-white"
          >
            <q-input
              filled
              type="password"
              v-model="gkKey"
              label="Github Key"
              lazy-rules
              :rules="[
                (val) =>
                  (val !== null && val !== '') || 'Please enter your key',
              ]"
              :error-message="gtKeyErrorMessage"
            />
            <div class="float-right">
              <q-btn flat label="Cancel" color="primary" v-close-popup />
              <q-btn flat label="Ok" type="submit" color="primary" />
            </div>
          </q-form>
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-page-container>
      <q-page class="full-height">
        <iframe
          ref="pageEditor"
          style="width: 100%; position: absolute; height: 100%; border: 0px"
          src="/#/blank"
        />
      </q-page>
      <q-page class="full-height">
        <textarea
          ref="pageEditorText"
          style="width: 100%; position: absolute; height: 100%; border: 0px"
          v-model="pageEditorText"
        />
      </q-page>
      <q-page-sticky position="bottom-right" :offset="[18, 18]">
        <q-fab
          vertical-actions-align="right"
          color="secondary"
          glossy
          icon="keyboard_arrow_up"
          direction="up"
        >
          <!-- <q-fab-action
            label-position="left"
            color="primary"
            @click="clearBackground"
            label="Remove Background"
          />
          <q-fab-action
            label-position="left"
            color="secondary"
            @click="joinLines"
            label="Join Lines"
          /> -->
          <q-fab-action
            label-position="left"
            color="orange"
            @click="detectLines"
            label="detect Lines"
          />
          <q-fab-action
            label-position="left"
            color="orange"
            @click="detectHymnLines"
            label="detect Hymn Lines"
          />
        </q-fab>
      </q-page-sticky>
      <q-page-sticky position="bottom-left" :offset="[18, 18]">
        <q-btn round color="primary" icon="save" @click="saveExtractedFile" />
      </q-page-sticky>
      <q-page-sticky position="right" :offset="[18, 18]">
        <q-btn
          round
          color="primary"
          icon="navigate_next"
          @click="nextOriginalFile"
        />
      </q-page-sticky>
      <q-page-sticky position="left" :offset="[18, 18]">
        <q-btn
          round
          color="primary"
          icon="navigate_before"
          @click="prevOriginalFile"
        />
      </q-page-sticky>
    </q-page-container>
  </q-layout>
</template>

<script>
const { Octokit } = require("@octokit/rest");
import { QSpinnerGears } from "quasar";
const to = require("await-to-js").to;
const axios = require("axios");
const owner = "GospelSounders";
const repo = "ch1941.adh";

export default {
  name: "MainLayout",
  components: {},
  computed: {
    // this.loggedIns = ths.loggedIn
  },
  created() {
    // check for credentials
    this.checkforCredentials();
    this.originalFilesList();
    // this.$q.loading.show({
    //         message: false
    //           ? "Registering your account..."
    //           : "Authenticating your account...",
    //         backgroundColor: "grey",
    //         spinner: QSpinnerGears,
    //         customClass: "loader",
    //       });
  },
  data() {
    return {
      pageEditorText: "",
      lines: [],
      allElements: [],
      leftDrawerOpen: false,
      openOriginal: false,
      loginDialog: false,
      loggedIn: false,
      gkKey: null,
      gtKeyErrorMessage: "",
      allOriginals: [],
      originals: [],
      originalFile: "",
    };
  },
  methods: {
    clearBackground() {
      let iframe = this.$refs.pageEditor.contentWindow.document;
      let bgImage = iframe.getElementsByTagName("img");
      for (let i in bgImage) {
        let img = bgImage[i];
        try {
          img.parentNode.removeChild(img);
        } catch (err) {}
      }

      var style = document.createElement("style");
      style.type = "text/css";
      style.innerHTML = `
      .bordered{
      border: 1px solid green;
      }
      `;
      iframe.getElementsByTagName("head")[0].appendChild(style);

      let page = iframe.getElementById("pf1");
      page = page.children[0];
      for (let i in page.children) {
        let child = page.children[i];

        try {
          if (!child.style) {
            child.style = {};
          }
        } catch (err) {}

        // this.detectLines();
      }
      this.detectLines();
    },
    joinLines() {
      let iframe = this.$refs.pageEditor.contentWindow.document;
      let page = iframe.getElementById("pf1");
      page = page.children[0];
      let children = [];
      for (let i in page.children) {
        let child = page.children[i];
        children.push(child);
      }
      children = children.filter((item) => {
        try {
          item.getBoundingClientRect();
          return item;
        } catch (err) {
          return false;
        }
      });
      children = children.sort((a, b) => {
        let aX = a.getBoundingClientRect().x;
        let aY = a.getBoundingClientRect().y;
        let bX = b.getBoundingClientRect().x;
        let bY = b.getBoundingClientRect().y;
        return aY - bY;
        //   return Math.hypot(aX, aY) - Math.hypot(bX, bY)
        //   a.getBoundingClientRect().y - b.getBoundingClientRect().y && a.getBoundingClientRect().x - b.getBoundingClientRect().x;
        //   a.getBoundingClientRect().x - b.getBoundingClientRect().x && a.getBoundingClientRect().y - b.getBoundingClientRect().y
      });
      this.allElements = children;
    },
    detectLines() {
      this.detectLines_();
    },
    detectLines_() {
      this.joinLines();
      this.pageEditorText = "";
      let allElements = this.allElements;
      let lines = [];
      let line = [];
      for (let i in allElements) {
        let elem = allElements[i];
        if (line.length === 0) {
          line.push(elem);
        } else {
          let oldItem = line[line.length - 1].getBoundingClientRect();
          let oldBottom = oldItem.top - oldItem.height;

          let thisItem = elem.getBoundingClientRect();
          let thisBottom = thisItem.top - thisItem.height;
          let lesserHeight =
            oldItem.height < thisItem.height ? oldItem.height : thisItem.height;
          if (Math.abs(oldBottom - thisBottom) < lesserHeight * 0.5) {
            line.push(elem);
          } else {
            // console.log(
            //   line
            //     .map((item) => item.innerHTML.replace(/<[^>]+>/g, ""))
            //     .join("")
            // );
            line = line.sort((a, b) => {
              let aX = a.getBoundingClientRect().x;
              let aY = a.getBoundingClientRect().y;
              let bX = b.getBoundingClientRect().x;
              let bY = b.getBoundingClientRect().y;
              return aX - bX;
            });
            let lineData = "";
            for (let i in line) {
              lineData += line[i].innerHTML;
            }
            line[0].innerHTML = `${lines.length}-->${lineData}`;
            this.pageEditorText += `\n${lineData.replace(/<[^>]+>/g, "")}`;
            for (let i in line) {
              if (i > 0) {
                line[i].parentNode.removeChild(line[i]);
              }
            }
            lines.push(line);
            line = [];
            line.push(elem);
          }
        }
      }
    },

    filterFn(val, update) {
      if (val === "") {
        update(() => {
          this.originals = this.allOriginals;
        });
        return;
      }

      update(() => {
        const needle = val.toLowerCase();
        this.originals = this.allOriginals.filter(
          (v) => v.toLowerCase().indexOf(needle) > -1
        );
      });
    },
    logout() {
      window.localStorage.removeItem("adhGitKey");
      this.checkforCredentials();
    },
    async saveExtractedFile() {
      let hymnNumber = this.pageEditorText.split("\n")[1];
      console.log(hymnNumber);
      if (parseInt(hymnNumber).toString() === hymnNumber) {
        hymnNumber = hymnNumber;
        while (hymnNumber.length < 3) hymnNumber = `0${hymnNumber}`;
      } else {
        hymnNumber = this.originalFile;
      }
      console.log(hymnNumber);
      let path = `extracted/${hymnNumber}`

       const octokit = new Octokit({
          auth: this.loggedIn,
        });

      let [err, care] = await to(
        octokit.request(
          `GET /repos/${owner}/${repo}/contents/${path}`,
          {
            owner: owner,
            repo: repo,
            path: path,
          }
        )
      );
      let sha;
      if (!err) {
        sha = care.data.sha;
      }
      let obj = {
        owner: owner,
        repo: repo,
        path: path,
        message: path,
        content: Buffer.from(this.pageEditorText ).toString("base64"),
      };
      if (sha) {
        obj.sha = sha;
      }
      [err, care] = await to(
        octokit.request(
          `PUT /repos/${owner}/${repo}/contents/${path}`,
          obj
        )
      );
    },
    async nextOriginalFile() {
      if (this.originalFile === "") this.originalFile = "page1";
      else {
        let tmp = parseInt(this.originalFile.replace("page", ""));
        tmp++;
        this.originalFile = `page${tmp}`;
      }
      this.onSubmitOpenOriginal();
    },
    async prevOriginalFile() {
      if (this.originalFile === "") this.originalFile = "page1";
      else {
        let tmp = parseInt(this.originalFile.replace("page", ""));
        tmp--;
        if (tmp < 1) tmp = 1;
        this.originalFile = `page${tmp}`;
      }
      this.onSubmitOpenOriginal();
    },
    async onSubmitOpenOriginal() {
      return new Promise(async (resolve, reject) => {
        const octokit = new Octokit({
          auth: this.loggedIn,
        });
        let owner = "GospelSounders";
        let repo = "ch1941.adh";
        let path = `splitOriginalFiles/${this.originalFile}.html`;
        let [err, care] = await to(
          axios.get(
            `https://raw.githubusercontent.com/GospelSounders/ch1941.adh/master/splitOriginalFiles/${this.originalFile}.html`
          )
        );
        this.openOriginal = false;
        if (err) {
          return resolve(false);
        }
        care = care.data;
        care = care.replace(";color:transparent", ";color:black");
        care = care.replace("{color:transparent", "{color:black");
        care = care.replace(".t{", ".t{border:1px solid green;");
        // this.$refs.pageEditor.contentDocument.write(care);
        this.$refs.pageEditor.srcdoc = care;
        setTimeout(() => {
          this.clearBackground();
        }, 2000);
      });
    },
    onSubmitgtKey() {
      window.localStorage.setItem("adhGitKey", this.gkKey);
      this.checkforCredentials();
      this.loginDialog = false;
    },
    onResetgtKey() {},
    checkforCredentials() {
      let hasGitCredentials = window.localStorage.getItem("adhGitKey");
      this.loggedIn = hasGitCredentials;
    },
    mouseOutofDrawer(pos) {
      if (Math.abs(pos.clientX - this.$refs.drawer.width) < 5) {
        this.leftDrawerOpen = false;
      }
    },
    originalFilesList() {
      let ret = {};
      this.allOriginals = [];
      for (let i = 1; i <= 637; i++) {
        ret[i] = `page${i}`;
        this.allOriginals.push(ret[i]);
      }
    },
  },
};
</script>
