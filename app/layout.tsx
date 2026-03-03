import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Litho-Arche: The Archive of Luminous Memories",
  description: "世界中の「まだ言葉にならない想い」や「忘れかけられた夢」を収集し、美しく分類・記録する図譜",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Caveat:wght@400;500;600;700&family=Kalam:wght@300;400;700&family=Permanent+Marker&family=Shadows+Into+Light&family=Indie+Flower&family=Amatic+SC:wght@400;700&family=Zen+Kurenaido&family=Kaisei+HarunoUmi:wght@400;500;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="antialiased">{children}</body>
    </html>
  );
}
