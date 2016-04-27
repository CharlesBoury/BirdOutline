using UnityEngine;

[ExecuteInEditMode]

public class SpriteOutline : MonoBehaviour {
    public bool interior = false; 
    public bool exterior = true; 
    public Color color = Color.white;
    [Range(0, 1)] public float alphaCorner = 1;

    private SpriteRenderer spriteRenderer;

    void OnEnable() {
        spriteRenderer = GetComponent<SpriteRenderer>();
        UpdateOutline(interior, exterior);
    }

    void OnDisable() {
        UpdateOutline(false, false);
    }

    void Update() {
        UpdateOutline(interior, exterior);
    }

    void UpdateOutline(bool interior, bool exterior) {
        MaterialPropertyBlock mpb = new MaterialPropertyBlock();
        spriteRenderer.GetPropertyBlock(mpb);
        mpb.SetFloat("_Interior", interior ? 1f : 0);
        mpb.SetFloat("_Exterior", exterior ? 1f : 0);
        mpb.SetColor("_OutlineColor", color);
        mpb.SetFloat("_OutlineAlphaCorner", alphaCorner);
        spriteRenderer.SetPropertyBlock(mpb);
    }
}