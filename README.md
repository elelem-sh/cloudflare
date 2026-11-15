# elelem-cloudflare

A [Cloudflare Workers AI](https://developers.cloudflare.com/workers-ai/) provider plugin for [elelem](https://elelem.sh).
It talks to Workers AI's OpenAI-compatible Chat Completions API
through [elelem-openai](https://github.com/elelem-sh/openai).

## Install

```sh
gem install elelem-cloudflare
```

## Use

```sh
export CLOUDFLARE_API_TOKEN=...
export CLOUDFLARE_ACCOUNT_ID=...
elelem -p cloudflare --model @cf/meta/llama-3.3-70b-instruct-fp8-fast
```

* `CLOUDFLARE_API_TOKEN` (required): a Workers AI API token.
* `CLOUDFLARE_ACCOUNT_ID` (required unless `CLOUDFLARE_BASE_URL` is set): your account ID.
* `CLOUDFLARE_MODEL`: the model, when `--model` is not given
* `CLOUDFLARE_BASE_URL`: overrides `https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/ai/v1`

Get both values on the Workers AI page of the dashboard, under **Use REST API**:
https://developers.cloudflare.com/workers-ai/get-started/rest-api/#1-get-api-token-and-account-id

A token you create yourself needs `Workers AI - Read` and `Workers AI - Edit`:
https://developers.cloudflare.com/fundamentals/api/get-started/create-token/

To find the account ID: https://developers.cloudflare.com/fundamentals/account/find-account-and-zone-ids/

Models: https://developers.cloudflare.com/workers-ai/models/

There is no default model, since free model lists change often. With
no model set, elelem stops and names `CLOUDFLARE_MODEL`. A variable that is
set but empty counts as unset.

Free tier limits are on Cloudflare's own page: https://developers.cloudflare.com/workers-ai/platform/limits/

## Development

```sh
bin/setup
bin/test
bin/lint
```

## License

MIT. See LICENSE.txt.
