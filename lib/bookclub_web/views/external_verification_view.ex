defmodule BookclubWeb.ExternalVerificationView do
  use BookclubWeb, :view

  def render("android_association.json", _opts) do
    [
      %{
        relation: ["delegate_permission/common.handle_all_urls"],
        target: %{
          namespace: "web",
          site: "https://bookclub-app.foxboxapp.com"
        }
      },
      %{
        relation: ["delegate_permission/common.handle_all_urls"],
        target: %{
          namespace: "app",
          package_name: "com.bookclubnow.bookclub",
          sha256_cert_fingerprints: ["55:AD:38:5E:37:08:A3:BD:F5:52:69:91:78:3E:50:52:D5:69:1C:88:07:69:9B:AD:09:2D:9D:E2:10:1D:C0:18"]
        }
      }
    ]
  end

  def render("ios_association.json", _opts) do
    %{
      applinks: %{
        apps: [],
        details: [
          %{
            appID: "BBWFVAFBX5.com.bookclubnow.bookclub",
            paths: ["*"]
          }
        ]
      }
    }
  end
end
