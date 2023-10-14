import json

import gradio as gr

from main import GPT4Wrapper, step3_get_lm_review

wrapper = GPT4Wrapper(model_name="gpt-4")


def process(title, abstract, figure_and_table_captions, main_content):
    parsed_xml = {
        "title": title,
        "abstract": abstract,
        "figure_and_table_captions": figure_and_table_captions,
        "main_content": main_content,
    }
    review_generated = step3_get_lm_review(parsed_xml)
    return review_generated["review_generated"]


def main():
    example_paper = json.load(open("example_paper.json"))
    input_fields = [
        gr.Textbox(
            label="Title",
            placeholder=example_paper["Title"],
        ),
        gr.Textbox(
            label="Abstract",
            lines=5,
            placeholder=example_paper["Abstract"],
        ),
        gr.Textbox(
            label="Figures/Tables Captions",
            lines=5,
            placeholder=example_paper["Figures/Tables Captions"],
        ),
        gr.Textbox(
            label="Main Content", lines=15, placeholder=example_paper["Main Content"]
        ),
    ]

    output_component_review = gr.Textbox(label="Review Generated")

    demo = gr.Interface(
        fn=process, inputs=input_fields, outputs=output_component_review
    )
    demo.launch(server_name="0.0.0.0", server_port=7799)


if __name__ == "__main__":
    main()
