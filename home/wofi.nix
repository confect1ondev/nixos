{ config, pkgs, ... }:

{
  programs.wofi = {
    enable = true;
    package = pkgs.wofi;
    
    settings = {
      # Window configuration
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = true;
      
      # Performance and behavior
      matching = "contains";
      exec_search = false;
      hide_scroll = true;
      
      # Key bindings
      key_expand = "Tab";
      key_exit = "Escape";
    };
    
    style = ''
      /* Main window styling */
      window {
        margin: 0px;
        border: 2px solid #4a90e2;
        border-radius: 12px;
        background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
        font-family: "Inter", "SF Pro Display", "Roboto", sans-serif;
        font-size: 14px;
        font-weight: 500;
        color: #e0e0e0;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        animation: slideIn 0.2s ease-out;
      }
      
      @keyframes slideIn {
        from {
          opacity: 0;
          transform: translateY(-10px) scale(0.98);
        }
        to {
          opacity: 1;
          transform: translateY(0) scale(1);
        }
      }
      
      /* Input field styling */
      #input {
        margin: 12px;
        padding: 12px 16px;
        border: 2px solid #3a3a3a;
        background: rgba(45, 45, 45, 0.8);
        border-radius: 8px;
        color: #e0e0e0;
        font-size: 16px;
        font-weight: 500;
        transition: all 0.2s ease;
        box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
      }
      
      #input:focus {
        border-color: #4a90e2;
        background: rgba(74, 144, 226, 0.1);
        box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.2);
      }
      
      #input image {
        color: #4a90e2;
        margin-right: 8px;
      }
      
      /* Container styling */
      #inner-box {
        margin: 8px;
        border: none;
        background: transparent;
      }
      
      #outer-box {
        margin: 0px;
        border: none;
        background: transparent;
      }
      
      #scroll {
        margin: 0px 8px 8px 8px;
        border: none;
        background: transparent;
      }
      
      /* List entries */
      #entry {
        padding: 12px 16px;
        margin: 2px 0;
        border: none;
        border-radius: 8px;
        background: transparent;
        color: #e0e0e0;
        transition: all 0.15s ease;
      }
      
      #entry:hover {
        background: rgba(74, 144, 226, 0.15);
        transform: translateX(4px);
      }
      
      #entry:selected {
        background: linear-gradient(90deg, #4a90e2 0%, #357abd 100%);
        color: #ffffff;
        font-weight: 600;
        box-shadow: 0 2px 8px rgba(74, 144, 226, 0.3);
        transform: translateX(4px);
      }
      
      /* Text styling */
      #text {
        margin: 0px;
        border: none;
        background: transparent;
        color: inherit;
        font-weight: inherit;
      }
      
      #text:selected {
        background: transparent;
        color: inherit;
      }
      
      /* Image/icon styling */
      #img {
        margin-right: 12px;
        border-radius: 6px;
        transition: all 0.15s ease;
      }
      
      #entry:selected #img {
        transform: scale(1.05);
      }
      
      /* Scrollbar styling */
      scrollbar {
        width: 6px;
        background: transparent;
      }
      
      scrollbar slider {
        background: rgba(74, 144, 226, 0.5);
        border-radius: 3px;
        min-height: 20px;
      }
      
      scrollbar slider:hover {
        background: rgba(74, 144, 226, 0.7);
      }
      
      /* Additional refinements */
      tooltip {
        background: rgba(26, 26, 26, 0.95);
        color: #e0e0e0;
        border: 1px solid #4a90e2;
        border-radius: 6px;
        padding: 8px 12px;
        font-size: 12px;
      }
      
      /* Responsive design for smaller screens */
      @media (max-width: 800px) {
        window {
          width: 90vw;
          max-width: 500px;
        }
      }
    '';
  };
}