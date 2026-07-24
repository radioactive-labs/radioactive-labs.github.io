# radioactive-labs.github.io

Marketing site for Radioactive Labs, the product studio.

## Deploy

This is the **organization root Pages site**. The repository MUST be named
`radioactive-labs.github.io` so GitHub Pages serves it at the org root:

    https://radioactive-labs.github.io/

Any other repo name would serve under a `/repo/` subpath instead.

To publish:

1. Create a repo named `radioactive-labs.github.io` under the `radioactive-labs`
   GitHub org.
2. Push this folder to its default branch.
3. In the repo Settings > Pages, set the source to the default branch, root.

The site is plain static HTML with inline CSS and no build step. `.nojekyll`
tells Pages to serve the files as-is without Jekyll processing.

## Before launch (open items)

- Replace the contact email `hello@radioactivelabs.dev` (search for
  `PLACEHOLDER` in `index.html`).
- Add any further featured products beyond UniversalChatbot.
- Add `assets/og-image.png` (1200x630) referenced by the OG meta tags.
- Optional: add a `CNAME` file if wiring a custom domain.
