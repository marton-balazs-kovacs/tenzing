/**
 * Rich clipboard support for tenzing
 *
 * Listens for Shiny custom messages and copies HTML + plain-text payloads
 * to the clipboard, falling back to plain text when rich copy is unavailable.
 */
(function () {
  const MESSAGE_ID = "tenzing-copy";

  function notifyStatus(status, detail, messageId) {
    if (typeof Shiny !== "undefined" && messageId) {
      Shiny.setInputValue(
        messageId,
        {
          status: status,
          detail: detail || null,
          timestamp: Date.now()
        },
        { priority: "event" }
      );
    }
  }

  function extractPlainTextFromHTML(html) {
    if (!html) {
      return "";
    }
    const container = document.createElement("div");
    container.innerHTML = html;
    return container.textContent || container.innerText || "";
  }

  function writeUsingExecCommand(text) {
    const textarea = document.createElement("textarea");
    textarea.value = text || "";
    textarea.setAttribute("readonly", "");
    textarea.style.position = "absolute";
    textarea.style.left = "-9999px";
    textarea.style.top = "-9999px";

    document.body.appendChild(textarea);
    textarea.select();

    let succeeded = false;
    try {
      succeeded = document.execCommand("copy");
    } catch (err) {
      succeeded = false;
    }

    document.body.removeChild(textarea);
    return succeeded;
  }

  async function writeRichClipboard(payload) {
    if (
      !navigator.clipboard ||
      typeof navigator.clipboard.write !== "function"
    ) {
      return false;
    }

    try {
      const clipboardItemData = {};

      if (payload.html) {
        clipboardItemData["text/html"] = new Blob([payload.html], {
          type: "text/html"
        });
      }

      const plainText =
        payload.text ||
        extractPlainTextFromHTML(payload.html) ||
        "";

      if (plainText) {
        clipboardItemData["text/plain"] = new Blob([plainText], {
          type: "text/plain"
        });
      }

      if (Object.keys(clipboardItemData).length === 0) {
        return false;
      }

      await navigator.clipboard.write([
        new ClipboardItem(clipboardItemData)
      ]);
      return true;
    } catch (err) {
      console.warn("tenzing clipboard write failed, falling back to text:", err);
      return false;
    }
  }

  function ensurePayload(payload) {
    if (!payload || typeof payload !== "object") {
      return {
        text: "",
        html: ""
      };
    }
    return payload;
  }

  if (typeof Shiny !== "undefined" && Shiny.addCustomMessageHandler) {
    Shiny.addCustomMessageHandler(MESSAGE_ID, async function (rawPayload) {
      const payload = ensurePayload(rawPayload);
      const statusInput = payload.statusInputId;
      const html = payload.html || "";
      const plainText =
        payload.text ||
        extractPlainTextFromHTML(html) ||
        "";

      let success = await writeRichClipboard({
        html: html,
        text: plainText
      });

      if (!success) {
        success = writeUsingExecCommand(plainText);
      }

      if (success) {
        notifyStatus("success", null, statusInput);
      } else {
        notifyStatus("error", "Clipboard copy failed", statusInput);
        console.error("tenzing clipboard: unable to copy content.");
      }
    });
  }
})();


