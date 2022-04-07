module.exports = {
  content: ['../lib/*_web/**/*.*ex', './js/**/*.js'],
  darkMode: 'class',
  plugins: [require('@tailwindcss/forms')],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: '#5221C3',
          50: '#C0ABF1',
          100: '#B399EE',
          200: '#9976E8',
          300: '#7F54E2',
          400: '#6531DC',
          500: '#5221C3',
          600: '#3E1993',
          700: '#2A1163',
          800: '#150933',
          900: '#010103',
        },
        'cod-gray': '#121212',
      },
    },
  },
};
