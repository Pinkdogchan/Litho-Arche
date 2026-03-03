import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // リト・アルケーのカラーパレット
        "luminous-blue": {
          50: "#e6f1ff",
          100: "#b3d9ff",
          200: "#80c1ff",
          300: "#4da9ff",
          400: "#1a91ff",
          500: "#0079e6",
          600: "#0061b3",
          700: "#004980",
          800: "#00314d",
          900: "#00191a",
        },
        "deep-night": {
          50: "#1a1a2e",
          100: "#16213e",
          200: "#0f1419",
          300: "#0a0e14",
          400: "#050709",
          500: "#000000",
        },
        "crystal-vein": {
          50: "#f0f9ff",
          100: "#e0f2fe",
          200: "#bae6fd",
          300: "#7dd3fc",
          400: "#38bdf8",
          500: "#0ea5e9",
        },
      },
      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
        "gradient-conic": "conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))",
        "starry-night": "radial-gradient(ellipse at bottom, #1a1a2e 0%, #0f1419 100%)",
      },
      animation: {
        "glow-pulse": "glow-pulse 3s ease-in-out infinite",
        "float": "float 6s ease-in-out infinite",
        "sparkle": "sparkle 2s ease-in-out infinite",
        "spiral-orbit": "spiral-orbit 25s linear infinite",
        "spiral-orbit-reverse": "spiral-orbit-reverse 25s linear infinite",
      },
      keyframes: {
        "glow-pulse": {
          "0%, 100%": { opacity: "0.6", transform: "scale(1)" },
          "50%": { opacity: "1", transform: "scale(1.05)" },
        },
        float: {
          "0%, 100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-20px)" },
        },
        sparkle: {
          "0%, 100%": { opacity: "0.3" },
          "50%": { opacity: "1" },
        },
        "spiral-orbit": {
          "0%": { transform: "rotate(0deg) translateX(var(--orbit-radius)) translateY(0px) rotate(0deg)" },
          "25%": { transform: "rotate(90deg) translateX(var(--orbit-radius)) translateY(-50px) rotate(-90deg)" },
          "50%": { transform: "rotate(180deg) translateX(var(--orbit-radius)) translateY(-100px) rotate(-180deg)" },
          "75%": { transform: "rotate(270deg) translateX(var(--orbit-radius)) translateY(-50px) rotate(-270deg)" },
          "100%": { transform: "rotate(360deg) translateX(var(--orbit-radius)) translateY(0px) rotate(-360deg)" },
        },
        "spiral-orbit-reverse": {
          "0%": { transform: "rotate(0deg) translateX(var(--orbit-radius)) translateY(0px) rotate(0deg)" },
          "25%": { transform: "rotate(-90deg) translateX(var(--orbit-radius)) translateY(50px) rotate(90deg)" },
          "50%": { transform: "rotate(-180deg) translateX(var(--orbit-radius)) translateY(100px) rotate(180deg)" },
          "75%": { transform: "rotate(-270deg) translateX(var(--orbit-radius)) translateY(50px) rotate(270deg)" },
          "100%": { transform: "rotate(-360deg) translateX(var(--orbit-radius)) translateY(0px) rotate(360deg)" },
        },
      },
    },
  },
  plugins: [],
};
export default config;
