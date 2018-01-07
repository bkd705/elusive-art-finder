defmodule ElusiveArtFinder do
  def fetch_page(url \\ "https://permanent-redirect.xyz") do
    IO.puts("Fetching URL: " <> url)
    response = HTTPoison.get!(url)
    case check_for_redirect(response) do
      {:redirect, next_url} -> fetch_page_with_sleep(next_url)
      {:found, url} -> IO.puts("Page Found, URL is: " <> url)
    end
  end

  defp fetch_page_with_sleep(next_url) do
    IO.puts("Sleeping...")
    :timer.sleep(1000)
    fetch_page(next_url)
  end

  defp check_for_redirect(%HTTPoison.Response{body: body, request_url: request_url} = response) do
    case String.contains?(body, "301 Permanent Redirect") do
      true -> {:redirect, get_redirect_url(response)}
      false -> {:found, request_url}
    end
  end

  defp get_redirect_url(%HTTPoison.Response{body: body} = response) do
    case Regex.run(~r/<a href="\.([\/\-\w]{1,})">/, body) do
      nil -> anchor_not_found!(response)
      [_, match] -> construct_next_url(match)
    end
  end

  defp construct_next_url(href) do
    case String.contains?(href, "pages") do
      true -> "https://permanent-redirect.xyz" <> href
      false -> "https://permanent-redirect.xyz/pages" <> href
    end
  end

  defp anchor_not_found!(%HTTPoison.Response{body: body, request_url: request_url}) do
    raise "Anchor not found. Url: " <> request_url <> " Body: " <> body
  end
end
