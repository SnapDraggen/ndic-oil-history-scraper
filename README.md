### Quick HTML scraper for history data

Usage:

```bash
ruby history-data.rb [file-number]
```

A `.csv` file is outputted. The file name is `output-<file-number>-<unix-epoch>.csv`

### Setup:

Copy the `auth.example.yml` to `auth.yml` in the same directory as
`history-data.rb` and update the `auth.yml` file so that the `Bearer: ` token is
accurate with your user.
