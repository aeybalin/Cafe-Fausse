import React, { useState } from "react";
import "./Gallery.css";

/* =========================================================
   IMPORT GALLERY IMAGES
   All files should be stored in:
   src/assets/gallery/
========================================================= */
import storeFront from "../assets/gallery/store-front.png";
import risotto from "../assets/gallery/risotto.png";
import ribeye from "../assets/gallery/ribeye.png";
import tiramisu from "../assets/gallery/tiramisu.png";
import cheesecake from "../assets/gallery/cheesecake.png";
import bruschetta from "../assets/gallery/bruschetta.png";
import caesarSalad from "../assets/gallery/caesar-salad.png";
import event from "../assets/gallery/event.png";

function Gallery() {
  /* =====================================================
     IMAGE LIST
     This is the order in which the carousel displays images
     You can add or remove images here later
  ====================================================== */
  const images = [
    storeFront,
    risotto,
    ribeye,
    tiramisu,
    cheesecake,
    bruschetta,
    caesarSalad,
    event,
  ];

  /* =====================================================
     CURRENT IMAGE INDEX
     Controls which image is shown in the main gallery window
  ====================================================== */
  const [currentIndex, setCurrentIndex] = useState(0);

  /* =====================================================
     LIGHTBOX STATE
     When true, the current image opens enlarged in overlay
  ====================================================== */
  const [isLightboxOpen, setIsLightboxOpen] = useState(false);

  /* =====================================================
     GO TO PREVIOUS IMAGE
     If at the first image, loop to the last one
  ====================================================== */
  function goToPrevious() {
    setCurrentIndex((prev) => (prev === 0 ? images.length - 1 : prev - 1));
  }

  /* =====================================================
     GO TO NEXT IMAGE
     If at the last image, loop to the first one
  ====================================================== */
  function goToNext() {
    setCurrentIndex((prev) => (prev === images.length - 1 ? 0 : prev + 1));
  }

  return (
    <div className="gallery-page">

      {/* =====================================================
          MAIN GALLERY IMAGE AREA
      ====================================================== */}
      <div className="gallery-main">

        {/* Main image container */}
        <div className="gallery-image-frame">
          <img
            src={images[currentIndex]}
            alt={`Gallery slide ${currentIndex + 1}`}
            className="gallery-main-image"
            onClick={() => setIsLightboxOpen(true)}
          />
        </div>

        {/* =================================================
            CAROUSEL CONTROLS
            Left arrow / dots / right arrow
        ================================================== */}
        <div className="gallery-controls">

          {/* Left arrow */}
          <button
            className="gallery-arrow"
            onClick={goToPrevious}
            aria-label="Previous image"
          >
            &#8249;
          </button>

          {/* dots */}
          <div className="gallery-dots">
            {images.map((_, index) => (
              <button
                key={index}
                className={`gallery-dot ${index === currentIndex ? "active" : ""}`}
                onClick={() => setCurrentIndex(index)}
                aria-label={`Go to image ${index + 1}`}
              />
            ))}
          </div>

          {/* Right arrow */}
          <button
            className="gallery-arrow"
            onClick={goToNext}
            aria-label="Next image"
          >
            &#8250;
          </button>
        </div>
      </div>

      {/* =====================================================
          LIGHTBOX OVERLAY
          Click anywhere outside or on image area to close
      ====================================================== */}
      {isLightboxOpen && (
        <div
          className="lightbox-overlay"
          onClick={() => setIsLightboxOpen(false)}
        >
          <img
            src={images[currentIndex]}
            alt={`Enlarged gallery slide ${currentIndex + 1}`}
            className="lightbox-image"
          />
        </div>
      )}

      {/* =====================================================
          BOTTOM 2-COLUMN SECTION
          Awards + Reviews
      ====================================================== */}
      <div className="gallery-bottom-grid">

        {/* ================= AWARDS ================= */}
        <div className="gallery-info-card">
          <h2 className="gallery-info-title">AWARDS</h2>

          <p className="gallery-info-text">Culinary Excellence Award – 2022</p>
          <p className="gallery-info-text">Restaurant of the Year – 2023</p>
          <p className="gallery-info-text">
            Best Fine Dining Experience – Foodie Magazine, 2023
          </p>
        </div>

        {/* ================= CUSTOMER REVIEWS ================= */}
        <div className="gallery-info-card">
          <h2 className="gallery-info-title">CUSTOMER REVIEWS</h2>

          <p className="gallery-review-quote">
            “Exceptional ambiance and unforgettable flavors.”
          </p>
          <p className="gallery-review-source">Gourmet Review</p>

          <p className="gallery-review-quote">
            “A must-visit restaurant for food enthusiasts.”
          </p>
          <p className="gallery-review-source">The Daily Bite</p>
        </div>
      </div>

    </div>
  );
}

export default Gallery;