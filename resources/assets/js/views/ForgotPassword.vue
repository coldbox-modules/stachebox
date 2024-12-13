<template>
  <div class="flex justify-center items-center h-screen px-6">
    <div class="p-6 max-w-sm w-full bg-white shadow-lg shadow-cyan-500/40">
      <div class="flex justify-center items-center">
        <img
          :src="`${baseHref}/includes/images/stachebox-logo-h.png`"
          style="width: 300px"
        />
      </div>
      <form v-if="!requestReceived" class="mt-4" @submit.prevent="requestReset">
        <p
          v-for="(error, index) in errors"
          :key="`error-${index}`"
          class="text-red-500 justify-center items-center"
        >
          {{ error }}
        </p>

        <label class="block">
          <span
            class="text-gray-700 text-sm"
            v-text="$t('Enter Your Email Address')"
          ></span>
          <input
            type="email"
            class="form-input rounded-none mt-1 block w-full focus:border-cyan-600"
            v-model="email"
            tabindex="1"
          />
        </label>

        <div class="mt-6">
          <button
            type="submit"
            class="py-2 px-4 text-center bg-theme w-full text-white text-sm"
            tabindex="3"
          >
            <span v-if="!isProcessing">{{ $t("Request Password Reset") }}</span>
            <span v-else
              >{{ $t("Requesting Password Reset") }}...
              <fa-icon icon="spinner" spin></fa-icon
            ></span>
          </button>
        </div>
      </form>
      <div class="items-center mt-5" v-else>
		<p class="text-green-400 text-sm-center">
			{{ $t("reset.request.received.message") }}
		</p>
        <br /><br />
        <button
          type="button"
          class="py-2 px-4 text-center bg-theme w-full text-white text-sm"
          tabindex="3"
          @click="$router.back()"
        >
          {{ $t("Return to Login") }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
import authAPI from "../api/authentication";

export default {
  data() {
    return {
      email: "",
      isProcessing: false,
      requestReceived: false,
      errors: [],
    };
  },
  computed: {
    ...mapState({
      baseHref: (state) => state.globals.stachebox.baseHref,
    }),
  },
  methods: {
    requestReset() {
      var self = this;
      self.isProcessing = true;
      authAPI
        .requestReset({ email: this.email })
        .then(() => self.requestReceived = true )
        .catch((err) => {
          console.error(err);
          self.errors.splice(0, self.errors.length);
          if (err.response) {
            err.response.data.messages.forEach((message) => self.errors.push(message));
          }
        });
    }
  },
};
</script>
