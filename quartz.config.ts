import { QuartzConfig } from "./quartz/cfg"
import * as Plugin from "./quartz/plugins"

/**
 * Quartz 4 Configuration
 *
 * See https://quartz.jzhao.xyz/configuration for more information.
 */
const config: QuartzConfig = {
  configuration: {
    pageTitle: "蜂职速聘 · 新媒体知识库",
    pageTitleSuffix: "",
    enableSPA: true,
    enablePopovers: true,
    analytics: null,
    locale: "zh-CN",
    baseUrl: "localhost",
    ignorePatterns: ["private", "templates", ".obsidian", ".WeDrive"],
    defaultDateType: "modified",
    theme: {
      fontOrigin: "googleFonts",
      cdnCaching: true,
      typography: {
        header: "Noto Sans SC",
        body: "Noto Sans SC",
        code: "IBM Plex Mono",
      },
      colors: {
        lightMode: {
          light: "#fdf8f5",
          lightgray: "#ebe4de",
          gray: "#b8a99e",
          darkgray: "#5c5046",
          dark: "#2d2520",
          secondary: "#c75b39",
          tertiary: "#4a8b8b",
          highlight: "rgba(199, 91, 57, 0.10)",
          textHighlight: "#f0d06088",
        },
        darkMode: {
          light: "#1b1b1e",
          lightgray: "#2d2b2e",
          gray: "#5c5a5e",
          darkgray: "#c8c6ca",
          dark: "#e8e6ea",
          secondary: "#e8815b",
          tertiary: "#6bb5b5",
          highlight: "rgba(232, 129, 91, 0.15)",
          textHighlight: "#8a7c2088",
        },
      },
    },
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({
        priority: ["frontmatter", "git", "filesystem"],
      }),
      Plugin.SyntaxHighlighting({
        theme: {
          light: "github-light",
          dark: "github-dark",
        },
        keepBackground: false,
      }),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.TableOfContents(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Description(),
      Plugin.Latex({ renderEngine: "katex" }),
    ],
    filters: [Plugin.RemoveDrafts()],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.TagPage(),
      Plugin.ContentIndex({
        enableSiteMap: true,
        enableRSS: true,
      }),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.Favicon(),
      Plugin.NotFoundPage(),
      // CustomOgImages disabled - Google Fonts inaccessible in China
      // Plugin.CustomOgImages(),
    ],
  },
}

export default config
