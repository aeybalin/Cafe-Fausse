import "./Footer.css";

function Footer({ openNewsletter }) {
  return (
    <footer className="footer">
      © Café Fausse, 2026. All rights reserved.

      {/* ✅ Floating Newsletter Button */}
      <button
        className="newsletter-float-button"
        onClick={openNewsletter}
        aria-label="Open newsletter signup"
      >
        ✉

        {/* ✅ Tooltip */}
        <span className="newsletter-tooltip">
          Join our Newsletter
        </span>
      </button>
    </footer>
  );
}

export default Footer;