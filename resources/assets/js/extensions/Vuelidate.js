import { helpers } from '@vuelidate/validators';

export const dictionary = {
    en: {
        custom:{
            passwordConfirmation: {
                confirmed: "Passwords do not match."
            }
        }
    }
}

export const validPassword = helpers.withMessage(
	"The Password must contain at least (2) UPPERCASE, (2) lowercase, (2) numb3rs, and (2) $pecial character$.",
	value => !helpers.req( value ) || ( new RegExp( "^(?=.*[a-z].*[a-z])(?=.*[A-Z].*[A-Z])(?=.*[0-9].*[0-9])(?=.*[!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~].*[!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~]).*$" ) ).test( value )
);