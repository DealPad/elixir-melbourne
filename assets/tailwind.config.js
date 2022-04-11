module.exports = {
  content: ['../lib/*_web/**/*.*ex', './js/**/*.js'],
  darkMode: 'class',
  plugins: [require('@tailwindcss/forms')],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: '#5716C7',
          50: '#BFA0F5',
          100: '#B38EF2',
          200: '#9A69EE',
          300: '#8144EA',
          400: '#6920E6',
          500: '#5716C7',
          600: '#411094',
          700: '#2B0B62',
          800: '#15052F',
          900: '#000000',
        },
        'cod-gray': '#121212',
      },
    },
  },
};
