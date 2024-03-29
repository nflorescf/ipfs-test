
2 - Create TOKEN

**CloudFlare**

dasdas




**Github Actions**

1- Create in repository
    Folder .github/
    Folder ./github/workflows
2 - Create build-release.yml
    
Required in secrets
 {secrets.TOKEN_GITHUB}
 {secrets.PINATA_API_KEY }
 {secrets.PINATA_API_SECRET_KEY}


    
    
```
name: Release
on: push
jobs:
  bump_version:
    name: Bump Version
    runs-on: ubuntu-latest
    outputs:
      new_tag: ${{ steps.github_tag_action.outputs.new_tag }}
      changelog: ${{ steps.github_tag_action.outputs.changelog }}
    steps:
      - name: Checkout
        uses: actions/checkout@v2
     
     - name: Set up node
        uses: actions/setup-node@v2
        with:
          node-version: 14
          registry-url: https://registry.npmjs.org

      - name: Install dependencies
        run: yarn install --frozen-lockfile

      - name: Build the IPFS bundle
        run: yarn build
        
      - name: Bump version and push tag
        id: github_tag_action
        uses: mathieudutour/github-tag-action@v6.0
        with:
          github_token: ${{ secrets.TOKEN_NF }}
          release_branches: master.*
          default_bump: false
          
  create_release:
    name: Create Release
    runs-on: ubuntu-latest
    needs: bump_version
    if: ${{ needs.bump_version.outputs.new_tag != null }}
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Pin to IPFS
        id: upload
        uses: anantaramdas/ipfs-pinata-deploy-action@39bbda1ce1fe24c69c6f57861b8038278d53688d
        with:
          pin-name: MoC ${{ needs.bump_version.outputs.new_tag }}
          path: './build'
          pinata-api-key: ${{ secrets.PINATA_API_KEY }}
          pinata-secret-api-key: ${{ secrets.PINATA_API_SECRET_KEY }}

      - name: Convert CIDv0 to CIDv1
        id: convert_cidv0
        uses: uniswap/convert-cidv0-cidv1@v1.0.0
        with:
          cidv0: ${{ steps.upload.outputs.hash }}



      - name: Create GitHub Release
        id: create_release
        uses: actions/create-release@v1.1.0
        env:
          GITHUB_TOKEN: ${{ secrets.TOKEN_NF }}
        with:
          tag_name: ${{ needs.bump_version.outputs.new_tag }}
          release_name: Release ${{ needs.bump_version.outputs.new_tag }}
          body: |
            IPFS hash of the deployment:
            - CIDv0: `${{ steps.upload.outputs.hash }}`
            - CIDv1: `${{ steps.convert_cidv0.outputs.cidv1 }}`
            The latest release is always accessible via our alias to the Cloudflare IPFS gateway at [ipfs.moneyonchain.com](https://ipfs.moneyonchain.com).
            You can also access the Moc Interface directly from an IPFS gateway.
            **BEWARE**: The MoC interface uses [`localStorage`](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage) to remember your settings, such as which tokens you have imported.
            **You should always use an IPFS gateway that enforces origin separation**, or our alias to the latest release at [app.uniswap.org](https://ipfs.moneyonchain.com.
            Your Uniswap settings are never remembered across different URLs.
            IPFS gateways:
            - https://gateway.pinata.cloud/ipfs/${{ steps.convert_cidv0.outputs.cidv1 }}
            - https://${{ steps.convert_cidv0.outputs.cidv1 }}.ipfs.dweb.link/
            - https://${{ steps.convert_cidv0.outputs.cidv1 }}.ipfs.cf-ipfs.com/
            - [ipfs://${{ steps.upload.outputs.hash }}/](ipfs://${{ steps.upload.outputs.hash }}/)
            ${{ needs.bump_version.outputs.changelog }}

