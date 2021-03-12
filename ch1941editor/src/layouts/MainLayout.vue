<template>
  <!-- <q-layout view="lHh Lpr lFf"> -->
  <q-layout view="hHh Lpr lFf">
    

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
                <q-item tag="a" @click="openOriginal=true">
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
      

      </q-list>
    </q-drawer>

    <q-dialog
      v-model="openOriginal"
      transition-show="rotate"
      transition-hide="rotate"
    >
      <q-card>
        <q-card-section class="q-pt-none">
         console.log('orginalashd ')
        </q-card-section>

        <q-card-actions align="right">
          <!-- <q-btn flat label="Decline" color="primary" v-close-popup /> -->
          <!-- <q-btn flat label="Accept" color="primary" v-close-popup /> -->
          <q-btn flat label="Cancel" color="primary" v-close-popup />
          <q-btn flat label="Ok" color="primary" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- <q-page-container>
      <router-view />
    </q-page-container> -->
  </q-layout>
</template>

<script>

export default {
  name: "MainLayout",
  components: {  },
  data() {
    return {
      leftDrawerOpen: false,
      openOriginal: false,
    };
  },
  methods: {
    mouseOutofDrawer(pos) {
      if (Math.abs(pos.clientX - this.$refs.drawer.width) < 5) {
        this.leftDrawerOpen = false;
      }
    },
    originalFilesList(){
      let ret = {};
      for (let i = 0; i<= 637;i++){
        ret[i] = `page`
      }
    }
  },
};
</script>
